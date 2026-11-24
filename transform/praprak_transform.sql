CREATE SCHEMA IF NOT EXISTS mart;

-- 1. Dimensi Customer (contoh sudah jadi)
CREATE OR REPLACE TABLE mart.dim_customer AS
SELECT
    customer_id,
    full_name,
    city,
    province,
    tier,
    updated_at
FROM raw.customers;

-- 2. TODO: Buat tabel `mart.fct_orders_mini` dengan melakukan JOIN antara
--    `raw.orders` dan `mart.dim_customer` berdasarkan `customer_id`.
--    Kolom minimal: order_id, order_date, customer_id, province, tier, status, shipping_fee, updated_at
--
-- CREATE OR REPLACE TABLE mart.fct_orders_mini AS
-- SELECT ...
