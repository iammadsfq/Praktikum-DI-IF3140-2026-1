#!/usr/bin/env bash
set -euo pipefail

# Dijalankan di dalam container elt-runner:
#   docker compose exec elt-runner bash /work/scripts/seed_oltp.sh

mkdir -p /work/data

echo "=== [1/2] Initializing partitioned OLTP schema ==="
psql "$POSTGRES_OLTP" -f /work/source/01_init_schema.sql

echo "=== [2/2] Seeding Day 1 data (50,000 orders / 100,000 order_items) ==="
psql "$POSTGRES_OLTP" -f /work/source/02_seed_day1.sql

echo "=== OLTP Row Counts (Day 1) ==="
psql "$POSTGRES_OLTP" -c "
SELECT 'customers' AS tbl, COUNT(*) FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments;
"
