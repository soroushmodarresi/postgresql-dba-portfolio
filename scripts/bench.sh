#!/usr/bin/env bash
# usage: scripts/bench.sh <label> [seconds]
set -euo pipefail
cd "$(dirname "$0")/.."
source .env
label="${1:?usage: bench.sh <label> [seconds]}"; secs="${2:-60}"
docker compose exec -T -e PGPASSWORD="$APP_RW_PASSWORD" postgres-primary \
  pgbench -h localhost -U app_rw -n -f /tuning/workload.sql -c 16 -j 4 -T "$secs" -P 10 appdb \
  | tee "tuning/bench_${label}.txt"
