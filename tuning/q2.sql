-- Q2: items for one product joined to paid orders
SELECT o.order_id, o.order_date, i.quantity
FROM shop.order_items i JOIN shop.orders o USING (order_id)
WHERE i.product_id = 777 AND o.status = 'paid';
