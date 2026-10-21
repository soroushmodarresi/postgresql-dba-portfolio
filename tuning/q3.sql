-- Q3: recent shipped orders (needs composite index)
SELECT count(*), sum(total) FROM shop.orders
WHERE status = 'shipped' AND order_date >= now() - interval '7 days';
