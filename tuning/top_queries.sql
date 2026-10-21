SELECT calls, round(total_exec_time::numeric,0) AS total_ms,
       round(mean_exec_time::numeric,2) AS mean_ms, left(query, 100) AS query
FROM pg_stat_statements
ORDER BY total_exec_time DESC LIMIT 10;
