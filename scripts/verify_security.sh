#!/usr/bin/env bash
# Quick security regression checks. Run after `make up`.
cd "$(dirname "$0")/.."
source .env
psql_as() { # user password sslmode args...
  local u=$1 p=$2 m=$3; shift 3
  docker compose exec -T -e PGPASSWORD="$p" -e PGSSLMODE="$m" postgres-primary psql -h localhost -U "$u" -d appdb "$@"
}
expect_ok()   { local d=$1; shift; if "$@" >/dev/null 2>&1; then echo "PASS  $d"; else echo "FAIL  $d"; fi; }
expect_fail() { local d=$1; shift; if "$@" >/dev/null 2>&1; then echo "FAIL  $d"; else echo "PASS  $d"; fi; }

expect_ok   "app_ro can SELECT over TLS"         psql_as app_ro "$APP_RO_PASSWORD" require -tAc "select 1 from shop.customers limit 1"
expect_fail "app_ro cannot INSERT"               psql_as app_ro "$APP_RO_PASSWORD" require -c "insert into shop.products(name,category,price) values('x','y',1)"
expect_ok   "app_rw can INSERT"                  psql_as app_rw "$APP_RW_PASSWORD" require -c "insert into shop.products(name,category,price) values('x','y',1)"
expect_fail "app_rw cannot CREATE in public"     psql_as app_rw "$APP_RW_PASSWORD" require -c "create table public.t(i int)"
expect_fail "app_rw cannot DROP shop tables"     psql_as app_rw "$APP_RW_PASSWORD" require -c "drop table shop.products"
expect_fail "app_rw rejected without TLS"        psql_as app_rw "$APP_RW_PASSWORD" disable -c "select 1"
expect_fail "wrong password rejected"            psql_as app_rw "wrong" require -c "select 1"
