#!/usr/bin/env bash
# Config tuning pass (sized for a ~4GB Docker VM; adjust to your machine).
cd "$(dirname "$0")/.."
PSQL="docker compose exec -T -u postgres postgres-primary psql -d appdb -v ON_ERROR_STOP=1"
$PSQL <<'SQL'
ALTER SYSTEM SET shared_buffers = '1GB';
ALTER SYSTEM SET effective_cache_size = '3GB';
ALTER SYSTEM SET work_mem = '32MB';
ALTER SYSTEM SET maintenance_work_mem = '256MB';
ALTER SYSTEM SET random_page_cost = 1.1;
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET max_wal_size = '4GB';
SQL
docker compose restart postgres-primary
