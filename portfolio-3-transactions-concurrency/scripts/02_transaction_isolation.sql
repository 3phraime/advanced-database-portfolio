
-- ============================================================
-- ShopSmart E-commerce and Inventory Management System
-- Portfolio 3: Transaction Isolation
-- PostgreSQL - READ COMMITTED
-- ============================================================

-- SESSION 1:
BEGIN;

UPDATE inventory
SET quantity_on_hand = 30
WHERE product_id = 1;

SELECT product_id, quantity_on_hand
FROM inventory
WHERE product_id = 1;

-- Keep this transaction open.
-- Check the same product from SESSION 2.
-- Session 2 should still see the previously committed value.

-- SESSION 1:
COMMIT;

-- SESSION 2:
-- Run this query again after Session 1 commits.

SELECT product_id, quantity_on_hand
FROM inventory
WHERE product_id = 1;
