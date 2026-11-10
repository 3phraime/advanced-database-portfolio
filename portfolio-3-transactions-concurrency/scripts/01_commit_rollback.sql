
-- ============================================================
-- ShopSmart E-commerce and Inventory Management System
-- Portfolio 3: Transaction Management
-- Demonstrating COMMIT and ROLLBACK
-- PostgreSQL
-- ============================================================

-- EXERCISE 1: COMMIT
-- Create a temporary test table.

CREATE TEMPORARY TABLE transaction_test (
    test_id INTEGER PRIMARY KEY,
    description VARCHAR(100)
);

-- Start a transaction.
BEGIN;

-- Insert a test record.
INSERT INTO transaction_test (test_id, description)
VALUES (1, 'Committed transaction');

-- Verify the inserted record.
SELECT * FROM transaction_test;

-- Save the transaction permanently within this session.
COMMIT;

-- Verify that the record remains available.
SELECT * FROM transaction_test;


-- EXERCISE 2: ROLLBACK

BEGIN;

-- Insert another test record.
INSERT INTO transaction_test (test_id, description)
VALUES (2, 'Rolled back transaction');

-- Verify the record before rollback.
SELECT * FROM transaction_test;

-- Undo the transaction.
ROLLBACK;

-- Verify that only the committed record remains.
SELECT * FROM transaction_test;
