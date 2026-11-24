\set orders_count 50000
\set customers_count 10000
\set products_count 500

-- 1. Customers
INSERT INTO customers (customer_id, full_name, city, province, tier, created_at, updated_at)
SELECT
    g AS customer_id,
    'Customer ' || lpad(g::TEXT, 6, '0') AS full_name,
    (ARRAY['Jakarta','Bandung','Surabaya','Medan','Semarang','Makassar','Palembang','Denpasar','Balikpapan','Yogyakarta'])[(g % 10) + 1] AS city,
    (ARRAY['DKI Jakarta','Jawa Barat','Jawa Timur','Sumatera Utara','Jawa Tengah','Sulawesi Selatan','Sumatera Selatan','Bali','Kalimantan Timur','DI Yogyakarta'])[(g % 10) + 1] AS province,
    (ARRAY['BRONZE','BRONZE','SILVER','SILVER','GOLD'])[(g % 5) + 1] AS tier,
    TIMESTAMP '2024-01-01 00:00:00' + ((g % 365) || ' days')::INTERVAL AS created_at,
    TIMESTAMP '2025-01-01 00:00:00' AS updated_at
FROM generate_series(1, :customers_count) AS g;

-- 2. Products
INSERT INTO products (product_id, sku, product_name, category, unit_price, updated_at)
SELECT
    g AS product_id,
    'SKU-' || lpad(g::TEXT, 5, '0') AS sku,
    'Product ' || g AS product_name,
    (ARRAY['Electronics','Fashion','Groceries','Home & Living','Health & Beauty','Sports'])[(g % 6) + 1] AS category,
    ROUND((15000 + ((g * 7919) % 485000))::NUMERIC, 2) AS unit_price,
    TIMESTAMP '2025-01-01 00:00:00' AS updated_at
FROM generate_series(1, :products_count) AS g;

-- 3. Orders (distributed across all 12 monthly partitions of 2025)
INSERT INTO orders (order_id, order_date, customer_id, status, shipping_fee, updated_at)
SELECT
    g AS order_id,
    (DATE '2025-01-01' + ((g * 13) % 365))::DATE AS order_date,
    ((g * 31) % :customers_count) + 1 AS customer_id,
    (ARRAY['DELIVERED','DELIVERED','DELIVERED','SHIPPED','PAID','PENDING','CANCELLED'])[(g % 7) + 1] AS status,
    (ARRAY[10000, 15000, 20000, 25000, 0])[(g % 5) + 1]::NUMERIC(10,2) AS shipping_fee,
    ((DATE '2025-01-01' + ((g * 13) % 365))::TIMESTAMP + INTERVAL '10 hours') AS updated_at
FROM generate_series(1, :orders_count) AS g;

-- 4. Order Items (2 items per order -> 100,000 rows)
INSERT INTO order_items (order_item_id, order_date, order_id, product_id, quantity, unit_price_at_order, discount_amount, updated_at)
SELECT
    ((o.order_id - 1) * 2) + item_no AS order_item_id,
    o.order_date,
    o.order_id,
    (((o.order_id * 17 + item_no * 29) % :products_count) + 1)::INTEGER AS product_id,
    ((o.order_id + item_no) % 4) + 1 AS quantity,
    p.unit_price AS unit_price_at_order,
    CASE WHEN (o.order_id % 5) = 0 THEN ROUND(p.unit_price * 0.10, 2) ELSE 0 END AS discount_amount,
    o.updated_at
FROM orders o
CROSS JOIN generate_series(1, 2) AS item_no
JOIN products p ON p.product_id = (((o.order_id * 17 + item_no * 29) % :products_count) + 1);

-- 5. Payments (1 payment per order)
INSERT INTO payments (payment_id, order_id, payment_method, payment_status, paid_amount, paid_at, updated_at)
SELECT
    o.order_id AS payment_id,
    o.order_id,
    (ARRAY['QRIS','VA_BCA','EWALLET','CC'])[(o.order_id % 4) + 1] AS payment_method,
    CASE
        WHEN o.status IN ('DELIVERED','SHIPPED','PAID') THEN 'SETTLED'
        WHEN o.status = 'PENDING' THEN 'PENDING'
        ELSE 'FAILED'
    END AS payment_status,
    COALESCE(oi.order_total, 0) + o.shipping_fee AS paid_amount,
    o.updated_at AS paid_at,
    o.updated_at
FROM orders o
JOIN (
    SELECT order_id, SUM(quantity * unit_price_at_order - discount_amount) AS order_total
    FROM order_items
    GROUP BY order_id
) oi ON oi.order_id = o.order_id;

ANALYZE customers;
ANALYZE products;
ANALYZE orders;
ANALYZE order_items;
ANALYZE payments;
