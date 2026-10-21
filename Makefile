.RECIPEPREFIX := >
-include .env
export

DC ?= docker compose
CUSTOMERS ?= 200000
PRODUCTS  ?= 20000
ORDERS    ?= 2000000
PGEXEC = $(DC) exec -T -u postgres postgres-primary

.PHONY: env up bootstrap load baseline tune-indexes tune-config after bench-before bench-after \
        backup-full backup-incr backup-info pitr failover-drill rebuild-replica replica-status \
        security-check top-queries ha-up ha-drill ha-down down clean

env:
> test -f .env || cp .env.example .env

up: env
> $(DC) up -d --build
> $(MAKE) bootstrap

bootstrap:
> until $(DC) exec -T postgres-primary pg_isready -U postgres -d appdb >/dev/null 2>&1; do sleep 2; done
> $(PGEXEC) pgbackrest --stanza=main stanza-create
> $(PGEXEC) psql -d appdb -c "CREATE EXTENSION IF NOT EXISTS pgaudit;"
> $(PGEXEC) pgbackrest --stanza=main check

load:
> $(PGEXEC) psql -d appdb -v ON_ERROR_STOP=1 -v customers=$(CUSTOMERS) -v products=$(PRODUCTS) -v orders=$(ORDERS) -f - < scripts/load_data.sql

baseline:
> scripts/run_queries.sh before

tune-indexes:
> $(PGEXEC) psql -d appdb -f - < tuning/fix_indexes.sql

tune-config:
> tuning/apply_config.sh

after:
> scripts/run_queries.sh after

bench-before:
> scripts/bench.sh before 60
bench-after:
> scripts/bench.sh after 60

backup-full:
> scripts/backup.sh full
backup-incr:
> scripts/backup.sh incr
backup-info:
> $(PGEXEC) pgbackrest --stanza=main info
pitr:
> scripts/pitr_drill.sh

failover-drill:
> scripts/failover_drill.sh
rebuild-replica:
> scripts/rebuild_replica.sh
replica-status:
> $(PGEXEC) psql -d appdb -x -c "select client_addr, state, sent_lsn, replay_lsn, replay_lag from pg_stat_replication;"

security-check:
> scripts/verify_security.sh
top-queries:
> $(PGEXEC) psql -d appdb -f - < tuning/top_queries.sql

ha-up: env
> $(DC) -f docker-compose.ha.yml up -d --build
ha-drill:
> scripts/ha_drill.sh
ha-down:
> $(DC) -f docker-compose.ha.yml down -v

down:
> $(DC) down
clean:
> $(DC) down -v
