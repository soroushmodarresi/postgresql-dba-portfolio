#!/usr/bin/env bash
# usage: scripts/backup.sh full|diff|incr
cd "$(dirname "$0")/.."
docker compose exec -T -u postgres postgres-primary pgbackrest --stanza=main --type="${1:-incr}" backup
docker compose exec -T -u postgres postgres-primary pgbackrest --stanza=main info
