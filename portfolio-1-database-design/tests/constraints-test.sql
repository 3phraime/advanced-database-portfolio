
-- ShopSmart: Portfolio 1 constraint tests
-- Each test is run separately against the populated shopsmart database.
-- Each INSERT is intentionally invalid and should be rejected.

-- Test 1: CHECK constraint
-- Expected: rejected because unit_price must be greater than zero.
INSERT INTO product (
    category_id, product_name, description, unit_price
)
VALUES (
    1, 'Constraint Test Product',
    'Temporary test of price validation', 0
);

-- Test 2: Foreign-key constraint
-- Expected: rejected because category 999 does not exist.
INSERT INTO product (
    category_id, product_name, description, unit_price
)
VALUES (
    999, 'Foreign Key Test Product',
    'Temporary test of category reference validation', 5000.00
);

-- Test 3: UNIQUE constraint
-- Expected: rejected because this email already exists.
INSERT INTO customer (
    first_name, last_name, email, address_line1, city
)
VALUES (
    'Test', 'Customer', 'amara.okafor@gmail.com',
    '1 Test Street', 'Abuja'
);
