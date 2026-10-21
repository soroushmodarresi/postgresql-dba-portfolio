#!/usr/bin/env bash
cd "$(dirname "$0")/.."
docker compose stop postgres-replica
docker compose rm -f postgres-replica
docker volume rm dba-portfolio_pgdata-replica 2>/dev/null || true
docker compose up -d postgres-replica
