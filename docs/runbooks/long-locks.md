# Runbook: long-running transactions and lock pile-ups

## Triage
1. Who is blocked and by whom:
```sql
SELECT blocked.pid AS blocked_pid, left(blocked.query,60) AS blocked_query,
       blocking.pid AS blocking_pid, left(blocking.query,60) AS blocking_query,
       now() - blocking.xact_start AS blocking_xact_age
FROM pg_stat_activity blocked
JOIN LATERAL unnest(pg_blocking_pids(blocked.pid)) b(pid) ON true
JOIN pg_stat_activity blocking ON blocking.pid = b.pid;
```
2. Idle in transaction? `SELECT pid, now()-xact_start, state FROM pg_stat_activity WHERE state='idle in transaction';`
3. Is DDL waiting behind a long query, queueing everything behind it? Look for `AccessExclusiveLock` waiters in Grafana → Locks by mode.

## Fix
- Prefer `pg_cancel_backend(blocking_pid)`; escalate to `pg_terminate_backend` if needed.
- Find the root cause with the app owners (missing commit, long batch job).

## Prevent
- `idle_in_transaction_session_timeout` (already set for app_rw), `lock_timeout` in migrations.
- `CREATE INDEX CONCURRENTLY` for production index builds.
