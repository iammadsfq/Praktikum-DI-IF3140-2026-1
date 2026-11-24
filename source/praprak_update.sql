-- 1) Update 1 customer (customer_id = 1 -> GOLD)
UPDATE customers
SET tier = 'GOLD', updated_at = TIMESTAMP '2025-12-31 23:59:59'
WHERE customer_id = 1;

-- 2) Update status 1 order lama (order_id = 1 -> REFUNDED)
UPDATE orders
SET status = 'REFUNDED', updated_at = TIMESTAMP '2025-12-31 23:59:59'
WHERE order_id = 1;

-- 3) Insert 1 order baru (order_id = 50001)
INSERT INTO orders (order_id, order_date, customer_id, status, shipping_fee, updated_at)
VALUES (50001, DATE '2025-12-31', 1, 'PAID', 15000.00, TIMESTAMP '2025-12-31 23:59:59')
ON CONFLICT (order_id, order_date) DO NOTHING;
