# Tuning results

> Fill this in from your own run. Nothing below is pre-populated on purpose;
> interviewers will ask about YOUR numbers.

Environment: _CPU / RAM / Docker VM size / dataset size (`make load` sizes)_

## Per-query (median of 3, ms) — from `tuning/results.csv`
| Query | Before | After indexes | After config | Fix |
|---|---|---|---|---|
| Q1 orders by customer | | | | index on orders(customer_id) |
| Q2 items by product + join | | | | index on order_items(product_id), orders PK join |
| Q3 recent shipped orders | | | | composite (status, order_date) |
| Q4 lower(email) lookup | | | | expression index |
| Q5 revenue by category | | | | orders(order_date), order_items(order_id), work_mem |

## pgbench (16 clients, 60s) — from `tuning/bench_*.txt`
| Stage | TPS | Avg latency (ms) |
|---|---|---|
| before | | |
| after indexes | | |
| after config | | |

## What I learned / what surprised me
-
