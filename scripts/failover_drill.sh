#!/usr/bin/env bash
# Manual failover: kill primary, promote replica, measure time until it accepts writes.
set -euo pipefail
cd "$(dirname "$0")/.."
echo "replica in recovery? $(docker compose exec -T -u postgres postgres-replica psql -d appdb -At -c 'select pg_is_in_recovery()')"
START=$(date +%s)
docker compose kill postgres-primary
docker compose exec -T -u postgres postgres-replica pg_ctl promote -D /var/lib/postgresql/data
until [ "$(docker compose exec -T -u postgres postgres-replica psql -d appdb -At -c 'select pg_is_in_recovery()' 2>/dev/null || echo t)" = "f" ]; do sleep 0.5; done
docker compose exec -T -u postgres postgres-replica psql -d appdb -c "CREATE TABLE IF NOT EXISTS shop.failover_probe(t timestamptz); INSERT INTO shop.failover_probe VALUES (now());"
echo "Manual failover time (kill -> first successful write): $(( $(date +%s) - START ))s"
echo "This excludes human detection time. Compare with: make ha-drill (Patroni)."
