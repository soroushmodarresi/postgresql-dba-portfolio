# Runbook: disk full / fast database growth
**Alert:** DatabaseGrowthFast (projected > 50GB in 24h)

## Triage
1. What is big? `SELECT relname, pg_size_pretty(pg_total_relation_size(oid)) FROM pg_class WHERE relkind='r' ORDER BY pg_total_relation_size(oid) DESC LIMIT 10;`
2. Is it WAL? `du -sh $PGDATA/pg_wal`. Growth here usually means:
   - failing `archive_command` (check `SELECT * FROM pg_stat_archiver;` and `pgbackrest check`),
   - an inactive replication slot or lagging replica (`SELECT slot_name, active FROM pg_replication_slots;`).
3. Bloat? Compare table size with expected row count; check `pg_stat_user_tables.n_dead_tup` and autovacuum activity.
4. Temp files? `log_temp_files` / `pg_stat_database.temp_bytes`.

## Fix (in order of safety)
- Fix the archive failure so WAL can be recycled. NEVER delete files from `pg_wal` by hand.
- Drop abandoned replication slots: `SELECT pg_drop_replication_slot('name');`
- Run `VACUUM (VERBOSE)` on the worst tables; for severe bloat use `pg_repack` (online) rather than `VACUUM FULL` (locks).
- Expire old backups: `pgbackrest --stanza=main expire`.
- Grow the volume.

## Prevent
Alert on disk usage as well as growth rate; keep archive failures alerting.
