#!/usr/bin/env bash
# Runs each tuning/q*.sql 3x with EXPLAIN ANALYZE and records the median execution time.
set -euo pipefail
cd "$(dirname "$0")/.."
label="${1:?usage: run_queries.sh <label>}"
out=tuning/results.csv
[ -f "$out" ] || echo "label,query,median_ms" > "$out"
for f in tuning/q*.sql; do
  sql=$(tr -d ';' < "$f")
  ts=()
  for i in 1 2 3; do
    ms=$(docker compose exec -T -u postgres postgres-primary psql -d appdb -At -c "EXPLAIN (ANALYZE) $sql" | awk '/Execution Time/{print $3}')
    ts+=("$ms")
  done
  med=$(printf '%s\n' "${ts[@]}" | sort -n | sed -n 2p)
  name=$(basename "$f" .sql)
  echo "$label,$name,$med" >> "$out"
  printf '%-8s %-6s %10s ms\n' "$label" "$name" "$med"
done
