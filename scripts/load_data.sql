-- usage: psql -v customers=200000 -v products=20000 -v orders=2000000 -f load_data.sql
\timing on
TRUNCATE shop.order_items, shop.orders, shop.products, shop.customers RESTART IDENTITY;

INSERT INTO shop.customers (email, name, country, created_at)
SELECT 'user' || g || '@example.com', 'Customer ' || g,
       (ARRAY['US','GB','DE','FR','IN','BR','JP','CA'])[1 + g % 8],
       now() - (random() * 730 || ' days')::interval
FROM generate_series(1, :customers) g;

INSERT INTO shop.products (name, category, price)
SELECT 'Product ' || g,
       (ARRAY['books','toys','tools','garden','kitchen','sports','music','beauty','auto','pets'])[1 + g % 10],
       round((5 + random() * 495)::numeric, 2)
FROM generate_series(1, :products) g;

INSERT INTO shop.orders (customer_id, status, order_date)
SELECT 1 + floor(random() * :customers)::bigint,
       (ARRAY['pending','paid','shipped','delivered','cancelled'])[1 + floor(random() * 5)::int],
       now() - (random() * 730 || ' days')::interval
FROM generate_series(1, :orders);

INSERT INTO shop.order_items (order_id, product_id, quantity, unit_price)
SELECT o.order_id, 1 + floor(random() * :products)::int, 1 + floor(random() * 5)::int,
       round((5 + random() * 495)::numeric, 2)
FROM shop.orders o
CROSS JOIN LATERAL generate_series(1, 1 + (o.order_id % 5)::int);

UPDATE shop.orders o SET total = s.t
FROM (SELECT order_id, sum(quantity * unit_price) AS t FROM shop.order_items GROUP BY order_id) s
WHERE s.order_id = o.order_id;

ANALYZE;
SELECT pg_size_pretty(pg_database_size(current_database())) AS db_size;
