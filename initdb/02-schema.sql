CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Only primary keys on purpose. Secondary indexes are added in tuning/fix_indexes.sql
CREATE TABLE shop.customers (
  customer_id bigserial PRIMARY KEY,
  email       text NOT NULL,
  name        text NOT NULL,
  country     char(2) NOT NULL,
  created_at  timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE shop.products (
  product_id serial PRIMARY KEY,
  name       text NOT NULL,
  category   text NOT NULL,
  price      numeric(10,2) NOT NULL
);
CREATE TABLE shop.orders (
  order_id    bigserial PRIMARY KEY,
  customer_id bigint NOT NULL,
  status      text NOT NULL,
  order_date  timestamptz NOT NULL,
  total       numeric(12,2) NOT NULL DEFAULT 0
);
CREATE TABLE shop.order_items (
  item_id    bigserial PRIMARY KEY,
  order_id   bigint NOT NULL,
  product_id int NOT NULL,
  quantity   int NOT NULL,
  unit_price numeric(10,2) NOT NULL
);
