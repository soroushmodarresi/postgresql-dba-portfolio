\set cid random(1, 200000)
\set pid random(1, 20000)
SELECT * FROM shop.orders WHERE customer_id = :cid;
SELECT order_id, quantity FROM shop.order_items WHERE product_id = :pid LIMIT 50;
SELECT customer_id FROM shop.customers WHERE lower(email) = format('user%s@example.com', :cid);
INSERT INTO shop.orders (customer_id, status, order_date, total) VALUES (:cid, 'pending', now(), 10);
