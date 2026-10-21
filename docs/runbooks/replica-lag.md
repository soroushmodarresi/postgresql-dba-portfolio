# Runbook: replica lag spike
**Alert:** ReplicationLagHigh (`pg_replication_lag_seconds > 30` for 2m)

## Triage
1. Is the replica connected? On primary: `make replica-status` (state should be `streaming`).
2. Is it network/IO or replay? On primary compare `sent_lsn` vs `replay_lsn`:
   - sent far ahead of replay → replica can't apply fast enough (IO/CPU, or a long query conflicting with replay).
   - sent behind current WAL → network or primary-side sender problem.
3. On replica, look for conflicting queries:
   `SELECT pid, now()-query_start AS age, left(query,80) FROM pg_stat_activity WHERE state='active' ORDER BY age DESC;`
4. Check primary for a write burst: Grafana → Transactions/sec, and `log_checkpoints` output.

## Fix
- Long replica query: cancel it (`pg_cancel_backend(pid)`); consider `hot_standby_feedback` / `max_standby_streaming_delay` tradeoffs.
- WAL removed before replica fetched it: rebuild with `make rebuild-replica`.
- Persistent: add IO capacity or reduce write amplification (batch size, index count).

## Verify
Lag back under 5s for 10 minutes; alert resolved.
