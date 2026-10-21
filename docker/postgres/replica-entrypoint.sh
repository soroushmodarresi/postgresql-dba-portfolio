#!/usr/bin/env bash
# Bootstraps a streaming replica from the primary on first start.
set -euo pipefail
export PGDATA="${PGDATA:-/var/lib/postgresql/data}"

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "[replica] empty data dir, taking base backup from postgres-primary"
  mkdir -p "$PGDATA" && chown postgres:postgres "$PGDATA" && chmod 700 "$PGDATA"
  # .pgpass so the walreceiver can authenticate after startup
  echo "postgres-primary:5432:*:replicator:${REPLICATOR_PASSWORD}" > /var/lib/postgresql/.pgpass
  chown postgres:postgres /var/lib/postgresql/.pgpass && chmod 600 /var/lib/postgresql/.pgpass
  until PGPASSWORD="$REPLICATOR_PASSWORD" pg_isready -h postgres-primary -U replicator >/dev/null 2>&1; do
    echo "[replica] waiting for primary..."; sleep 2
  done
  gosu postgres env PGPASSWORD="$REPLICATOR_PASSWORD" \
    pg_basebackup -h postgres-primary -U replicator -D "$PGDATA" -R -X stream --checkpoint=fast -P
  chmod 700 "$PGDATA"
fi
exec docker-entrypoint.sh "$@"
