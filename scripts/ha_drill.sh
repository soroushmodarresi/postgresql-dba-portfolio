#!/usr/bin/env bash
# Patroni failover drill: kill the leader, time how long until writes work again via HAProxy.
set -euo pipefail
cd "$(dirname "$0")/.."
source .env
HA="docker compose -f docker-compose.ha.yml"
leader=""; survivor=""
for n in patroni1 patroni2; do
  code=$($HA exec -T $n curl -s -o /dev/null -w '%{http_code}' localhost:8008/primary || true)
  if [ "$code" = "200" ]; then leader=$n; else survivor=$n; fi
done
echo "leader=$leader survivor=$survivor"
START=$(date +%s)
$HA kill "$leader"
until [ "$($HA exec -T -e PGPASSWORD="$POSTGRES_PASSWORD" "$survivor" psql -h haproxy -p 5000 -U postgres -At -c 'select pg_is_in_recovery()' 2>/dev/null || echo t)" = "f" ]; do sleep 1; done
echo "Automated failover time (kill -> writable via HAProxy): $(( $(date +%s) - START ))s"
echo "Bring the old leader back as a replica with: $HA up -d $leader"
