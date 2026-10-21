#!/usr/bin/env bash
# Point-in-time recovery drill: create data, record a timestamp, destroy the data,
# restore to just before the "mistake", and time the whole recovery.
set -euo pipefail
cd "$(dirname "$0")/.."
PSQL="docker compose exec -T -u postgres postgres-primary psql -d appdb -v ON_ERROR_STOP=1 -At"

echo "== 1. create demo data"
$PSQL -c "DROP TABLE IF EXISTS shop.pitr_demo; CREATE TABLE shop.pitr_demo AS SELECT g AS id FROM generate_series(1,1000) g;"
sleep 2
TARGET=$($PSQL -c "SELECT clock_timestamp()::text")
echo "   recovery target: $TARGET"
sleep 2

echo "== 2. disaster: drop the table"
$PSQL -c "DROP TABLE shop.pitr_demo;"
$PSQL -c "SELECT pg_switch_wal();" >/dev/null
sleep 5   # let archive_command ship the WAL segment

echo "== 3. restore (timed)"
START=$(date +%s)
docker compose stop postgres-primary
docker compose run --rm --no-deps -u postgres --entrypoint pgbackrest postgres-primary \
  --stanza=main --delta --type=time "--target=$TARGET" --target-action=promote restore
docker compose start postgres-primary
until docker compose exec -T postgres-primary pg_isready -U postgres -d appdb >/dev/null 2>&1; do sleep 1; done
# wait until recovery finishes and promotes
until [ "$($PSQL -c 'SELECT pg_is_in_recovery()' 2>/dev/null || echo t)" = "f" ]; do sleep 1; done
END=$(date +%s)

echo "== 4. verify"
ROWS=$($PSQL -c "SELECT count(*) FROM shop.pitr_demo")
echo "   rows recovered: $ROWS (expected 1000)"
echo "   RTO for this drill: $((END-START)) seconds"
echo "NOTE: the replica is now on a different timeline. Run: make rebuild-replica"
