
-- ============================================================
-- ShopSmart E-commerce and Inventory Management System
-- Portfolio 3: Concurrency Control
-- PostgreSQL
--
-- Demonstrates concurrent inventory updates using
-- two separate PostgreSQL sessions.
-- ============================================================

-- SESSION 1
-- Start a transaction and deduct 5 units.

BEGIN;

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 5,
    last_updated = CURRENT_TIMESTAMP
WHERE product_id = 1;

-- Keep this transaction open.
-- Do not commit until Session 2 attempts its update.

-- After Session 2 attempts its update, execute:
COMMIT;


-- SESSION 2
-- Execute these statements in the second terminal.

BEGIN;

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 8,
    last_updated = CURRENT_TIMESTAMP
WHERE product_id = 1;

-- This update waits while Session 1 holds the row lock.
-- After Session 1 commits, this update can continue.

COMMIT;


-- Verify the final inventory quantity.

SELECT
    product_id,
    quantity_on_hand
FROM inventory
WHERE product_id = 1;
