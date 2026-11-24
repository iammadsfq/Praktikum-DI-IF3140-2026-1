DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id  INTEGER PRIMARY KEY,
    full_name    VARCHAR(100) NOT NULL,
    city         VARCHAR(60)  NOT NULL,
    province     VARCHAR(60)  NOT NULL,
    tier         VARCHAR(20)  NOT NULL CHECK (tier IN ('BRONZE', 'SILVER', 'GOLD')),
    created_at   TIMESTAMP    NOT NULL,
    updated_at   TIMESTAMP    NOT NULL
);

CREATE TABLE products (
    product_id   INTEGER PRIMARY KEY,
    sku          VARCHAR(32)    NOT NULL UNIQUE,
    product_name VARCHAR(120)   NOT NULL,
    category     VARCHAR(50)    NOT NULL,
    unit_price   NUMERIC(12, 2) NOT NULL,
    updated_at   TIMESTAMP      NOT NULL
);

CREATE TABLE orders (
    order_id     BIGINT         NOT NULL,
    order_date   DATE           NOT NULL,
    customer_id  INTEGER        NOT NULL REFERENCES customers(customer_id),
    status       VARCHAR(20)    NOT NULL,
    shipping_fee NUMERIC(10, 2) NOT NULL,
    updated_at   TIMESTAMP      NOT NULL,
    PRIMARY KEY (order_id, order_date)
) PARTITION BY RANGE (order_date);

CREATE TABLE order_items (
    order_item_id       BIGINT         NOT NULL,
    order_date          DATE           NOT NULL,
    order_id            BIGINT         NOT NULL,
    product_id          INTEGER        NOT NULL REFERENCES products(product_id),
    quantity            INTEGER        NOT NULL,
    unit_price_at_order NUMERIC(12, 2) NOT NULL,
    discount_amount     NUMERIC(12, 2) NOT NULL DEFAULT 0,
    updated_at          TIMESTAMP      NOT NULL,
    PRIMARY KEY (order_item_id, order_date)
) PARTITION BY RANGE (order_date);

CREATE TABLE payments (
    payment_id     BIGINT         PRIMARY KEY,
    order_id       BIGINT         NOT NULL,
    payment_method VARCHAR(20)    NOT NULL,
    payment_status VARCHAR(20)    NOT NULL,
    paid_amount    NUMERIC(14, 2) NOT NULL,
    paid_at        TIMESTAMP      NOT NULL,
    updated_at     TIMESTAMP      NOT NULL
);

DO $$
DECLARE
    m_start DATE := DATE '2025-01-01';
    m_end   DATE;
    suffix  TEXT;
BEGIN
    WHILE m_start <= DATE '2026-01-01' LOOP
        m_end  := (m_start + INTERVAL '1 month')::DATE;
        suffix := to_char(m_start, 'YYYY_MM');

        EXECUTE format(
            'CREATE TABLE orders_%s PARTITION OF orders FOR VALUES FROM (%L) TO (%L)',
            suffix, m_start, m_end
        );
        EXECUTE format(
            'CREATE TABLE order_items_%s PARTITION OF order_items FOR VALUES FROM (%L) TO (%L)',
            suffix, m_start, m_end
        );

        m_start := m_end;
    END LOOP;
END $$;

CREATE TABLE orders_default      PARTITION OF orders      DEFAULT;
CREATE TABLE order_items_default PARTITION OF order_items DEFAULT;

CREATE INDEX idx_customers_updated_at   ON customers(updated_at);
CREATE INDEX idx_products_updated_at    ON products(updated_at);
CREATE INDEX idx_orders_updated_at      ON orders(updated_at);
CREATE INDEX idx_order_items_updated_at ON order_items(updated_at);
CREATE INDEX idx_payments_updated_at    ON payments(updated_at);
