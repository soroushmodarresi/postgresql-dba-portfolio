# Disaster drill log
Fill in after running each drill. Real numbers beat estimates.

| Drill | Command | Date | Result / time | Notes |
|---|---|---|---|---|
| PITR to just before DROP TABLE | `make backup-full && make pitr` | | RTO: __ s, rows recovered: __ | |
| Manual failover (kill primary, promote replica) | `make failover-drill` | | __ s | detection was manual |
| Automated failover (Patroni) | `make ha-up` then `make ha-drill` | | __ s | |
| Replica rebuild | `make rebuild-replica` | | __ s | |

## Findings
- What broke or surprised me:
- What I'd change in the runbooks:
