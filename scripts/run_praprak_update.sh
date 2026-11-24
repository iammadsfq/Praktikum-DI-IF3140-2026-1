#!/usr/bin/env bash
set -euo pipefail

# Dijalankan di dalam container elt-runner:
#   docker compose exec elt-runner bash /work/scripts/run_praprak_update.sh

echo "=== Running Prapraktikum mini-update on OLTP ==="
psql "$POSTGRES_OLTP" -f /work/source/praprak_update.sql

echo "=== Updated rows in OLTP ==="
psql "$POSTGRES_OLTP" -c "SELECT customer_id, tier, updated_at FROM customers WHERE customer_id = 1;"
psql "$POSTGRES_OLTP" -c "SELECT order_id, order_date, status, updated_at FROM orders WHERE order_id IN (1, 50001) ORDER BY order_id;"
