# PostgreSQL DBA Portfolio Project

A reproducible, production-style PostgreSQL environment that demonstrates the core DBA skills:
backup/PITR, replication and failover, monitoring, performance tuning, and security.

| Area | What's here |
|---|---|
| Backup & recovery | pgBackRest (full/incr + WAL archiving), timed PITR drill |
| Replication | Streaming replica; Patroni + etcd + HAProxy automated failover |
| Monitoring | postgres_exporter, Prometheus alerts, Grafana dashboard |
| Tuning | Seeded slow queries, `EXPLAIN ANALYZE` harness, pgbench workload |
| Security | Least-privilege roles, TLS-only app access, pgaudit, automated checks |
| Runbooks | Replica lag, disk full, lock pile-ups, disaster-drill log |

Architecture and design decisions: [docs/architecture.md](docs/architecture.md)

## Quick start
Requires Docker with Compose v2 and `make`. Give Docker ~4GB RAM.

```bash
make up            # builds image, starts primary+replica+monitoring, creates pgBackRest stanza
make load          # generates ~2M orders / ~6M order items (CUSTOMERS= PRODUCTS= ORDERS= to resize)
make backup-full
```
Grafana: http://localhost:3000 (admin / `GRAFANA_PASSWORD` from `.env`) · Prometheus: http://localhost:9090

## Walkthrough
1. **Backups + PITR**: `make backup-full`, then `make pitr`. The script creates data, records a timestamp, drops the table, restores to that timestamp, and prints the recovery time. Schedule: `scripts/crontab.example`.
2. **Monitoring**: open the *PostgreSQL Overview* dashboard; run `make bench-before` to generate load. Alerts are in `monitoring/alerts.yml`.
3. **Tuning** (record numbers in `tuning/RESULTS.md`):
   ```bash
   make baseline && make bench-before
   make tune-indexes && make after && make bench-after
   make tune-config                 # restarts primary with tuned memory settings
   make top-queries                 # pg_stat_statements view
   ```
4. **Replication / failover**: `make replica-status`; `make failover-drill` (manual). For automated failover: `make down`, then `make ha-up` and `make ha-drill`.
5. **Security**: `make security-check` verifies role permissions, TLS enforcement and rejected logins.
6. **Document it**: fill in `docs/runbooks/disaster-drill.md` and `tuning/RESULTS.md`, add Grafana screenshots.

## Layout
```
docker/          custom Postgres image (pgBackRest, pgaudit, TLS) and Patroni image
config/          postgresql.conf, pg_hba.conf, Patroni, HAProxy
initdb/          roles and schema, run on first start
scripts/         backup, PITR drill, failover drills, benchmarks, security checks
tuning/          slow queries, fixes, pgbench workload, results template
monitoring/      Prometheus, alert rules, Grafana provisioning
docs/            architecture and runbooks
```

## Status / honesty notes
- Config and scripts were written together but have **not been run end to end by the author yet**. First run, expect to fix small things (image tags, exporter metric names). Log what you fixed in the drill log; it makes a good interview story.
- Passwords in `.env.example` are placeholders. The TLS cert is self-signed and the backup repo is a local volume; both are demo shortcuts (see "What I'd do differently").
