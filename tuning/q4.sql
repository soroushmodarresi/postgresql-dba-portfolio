-- Q4: case-insensitive email lookup (needs expression index)
SELECT * FROM shop.customers WHERE lower(email) = 'user12345@example.com';
