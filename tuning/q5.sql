-- Q5: revenue by category, last 30 days (3-table join + aggregate)
SELECT p.category, sum(i.quantity * i.unit_price) AS revenue
FROM shop.order_items i
JOIN shop.products p USING (product_id)
JOIN shop.orders o USING (order_id)
WHERE o.order_date >= now() - interval '30 days'
GROUP BY p.category ORDER BY revenue DESC;
