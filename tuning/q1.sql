-- Q1: orders for one customer (no index on customer_id)
SELECT * FROM shop.orders WHERE customer_id = 4242;
