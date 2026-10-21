CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_customer     ON shop.orders (customer_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_status_date  ON shop.orders (status, order_date);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_date         ON shop.orders (order_date);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_items_product       ON shop.order_items (product_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_items_order         ON shop.order_items (order_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_customers_lower_email ON shop.customers (lower(email));
ANALYZE;
