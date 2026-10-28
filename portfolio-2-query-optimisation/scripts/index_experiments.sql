
-- ============================================================
-- ShopSmart E-commerce and Inventory Management System
-- Portfolio 2: Index Experiments and Query Execution Plans
-- Database: PostgreSQL
--
-- Purpose:
-- 1. Document the indexes used in the experiment.
-- 2. Inspect the execution plan for the full business query.
-- 3. Inspect index usage in two targeted queries.
--
-- IMPORTANT:
-- The indexes already exist in the current ShopSmart database.
-- Run the CREATE INDEX statements only in a fresh test database
-- where these indexes have not already been created.
-- ============================================================


-- ============================================================
-- EXPERIMENT 1: INDEX DEFINITIONS
-- Run these statements only once in a suitable test database.
-- ============================================================

CREATE INDEX idx_customer_order_customer_id
ON customer_order(customer_id);

CREATE INDEX idx_order_item_order_id
ON order_item(order_id);


-- ============================================================
-- EXPERIMENT 2: BASELINE / FULL BUSINESS QUERY PLAN
-- This is the same SELECT query used in business_queries.sql.
--
-- For the baseline, run before creating the two indexes.
-- Then run it again after creating each index to compare plans.
-- ============================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    co.order_id,
    co.order_date,
    co.status AS order_status,
    p.product_name,
    oi.quantity,
    oi.unit_price_at_purchase,
    oi.quantity * oi.unit_price_at_purchase AS line_total
FROM customer AS c
JOIN customer_order AS co
    ON c.customer_id = co.customer_id
JOIN order_item AS oi
    ON co.order_id = oi.order_id
JOIN product AS p
    ON oi.product_id = p.product_id
ORDER BY
    co.order_id,
    oi.order_item_id;


-- ============================================================
-- EXPERIMENT 3: TARGETED CUSTOMER FILTER
-- Expected index: idx_customer_order_customer_id
-- ============================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_id,
    customer_id,
    order_date,
    status
FROM customer_order
WHERE customer_id = 73;


-- ============================================================
-- EXPERIMENT 4: TARGETED ORDER-ITEM FILTER
-- Expected index: idx_order_item_order_id
-- ============================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price_at_purchase
FROM order_item
WHERE order_id = 1486;


-- ============================================================
-- END OF INDEX EXPERIMENTS
-- ============================================================
