-- ============================================================
-- ShopSmart E-commerce and Inventory Management System
-- Sample Data Generation and Verification
-- PostgreSQL
--
-- IMPORTANT:
-- This script documents the generation workflow.
-- Do not rerun INSERT/UPDATE/DELETE sections on the populated
-- database without resetting to a clean schema first.
-- ============================================================


-- ============================================================
-- 1. GENERATE 498 ADDITIONAL ORDERS
-- ============================================================

INSERT INTO customer_order (customer_id, order_date, status)
SELECT
    c.customer_id,
    CURRENT_TIMESTAMP - (random() * INTERVAL '365 days'),
    (ARRAY[
        'Pending', 'Processing', 'Shipped',
        'Delivered', 'Cancelled'
    ])[1 + floor(random() * 5)::INTEGER]
FROM generate_series(1, 498) AS g(n)
CROSS JOIN LATERAL (
    SELECT customer_id
    FROM customer
    ORDER BY random()
    LIMIT 1
) AS c;


-- ============================================================
-- 2. REDISTRIBUTE GENERATED ORDERS ACROSS CUSTOMERS
-- Preserves original orders 1 and 2.
-- ============================================================

WITH numbered_orders AS (
    SELECT
        order_id,
        ROW_NUMBER() OVER (ORDER BY order_id) AS rn
    FROM customer_order
    WHERE order_id NOT IN (1, 2)
),
numbered_customers AS (
    SELECT
        customer_id,
        ROW_NUMBER() OVER (ORDER BY customer_id) AS rn
    FROM customer
)
UPDATE customer_order AS co
SET customer_id = nc.customer_id
FROM numbered_orders AS no
JOIN numbered_customers AS nc
    ON nc.rn = ((no.rn - 1) % (SELECT COUNT(*) FROM customer)) + 1
WHERE co.order_id = no.order_id;


-- ============================================================
-- 3. GENERATE ORDER ITEMS
-- Adds two or three items to each generated order.
-- ============================================================

INSERT INTO order_item (
    order_id,
    product_id,
    quantity,
    unit_price_at_purchase
)
SELECT
    co.order_id,
    p.product_id,
    1 + floor(random() * 4)::INTEGER,
    p.unit_price
FROM customer_order AS co
CROSS JOIN LATERAL generate_series(
    1,
    2 + (co.order_id % 2)
) AS item_number(n)
JOIN LATERAL (
    SELECT product_id, unit_price
    FROM product
    ORDER BY random() * (item_number.n + co.order_id)
    LIMIT 1
) AS p ON TRUE
WHERE co.order_id NOT IN (1, 2);


-- ============================================================
-- 4. GENERATE MISSING PAYMENT RECORDS
-- Payment amounts are calculated from order items.
-- ============================================================

INSERT INTO payment (
    order_id,
    amount,
    payment_method,
    payment_status,
    payment_date,
    transaction_reference
)
SELECT
    co.order_id,
    totals.order_total,
    (ARRAY[
        'Card', 'Bank Transfer',
        'Cash on Delivery', 'Mobile Payment'
    ])[1 + floor(random() * 4)::INTEGER],
    (ARRAY['Pending', 'Paid', 'Failed'])
        [1 + floor(random() * 3)::INTEGER],
    CASE
        WHEN random() < 0.7
        THEN co.order_date + INTERVAL '1 hour'
        ELSE NULL
    END,
    'TXN-SM-' || co.order_id
FROM customer_order AS co
JOIN (
    SELECT
        order_id,
        SUM(quantity * unit_price_at_purchase) AS order_total
    FROM order_item
    GROUP BY order_id
) AS totals
    ON totals.order_id = co.order_id
WHERE NOT EXISTS (
    SELECT 1
    FROM payment AS pay
    WHERE pay.order_id = co.order_id
);


-- ============================================================
-- 5. GENERATE DELIVERIES ONLY FOR ELIGIBLE ORDERS
-- Requires Paid payment and non-Cancelled order status.
-- Preserves existing delivery records.
-- ============================================================

INSERT INTO delivery (
    order_id,
    delivery_address,
    delivery_status,
    shipped_date,
    delivered_date,
    tracking_number
)
SELECT
    co.order_id,
    c.address_line1 || ', ' || c.city ||
        COALESCE(', ' || c.postal_code, ''),
    CASE
        WHEN co.status = 'Delivered' THEN 'Delivered'
        WHEN co.status = 'Shipped' THEN 'Shipped'
        ELSE 'Pending'
    END,
    CASE
        WHEN co.status IN ('Shipped', 'Delivered')
        THEN co.order_date + INTERVAL '1 day'
        ELSE NULL
    END,
    CASE
        WHEN co.status = 'Delivered'
        THEN co.order_date + INTERVAL '3 days'
        ELSE NULL
    END,
    'SM-TRK-' || co.order_id
FROM customer_order AS co
JOIN customer AS c
    ON c.customer_id = co.customer_id
JOIN payment AS p
    ON p.order_id = co.order_id
WHERE p.payment_status = 'Paid'
  AND co.status <> 'Cancelled'
  AND NOT EXISTS (
      SELECT 1
      FROM delivery AS d
      WHERE d.order_id = co.order_id
  );


-- ============================================================
-- 6. VERIFY TABLE COUNTS
-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS total FROM customer
UNION ALL
SELECT 'categories', COUNT(*) FROM category
UNION ALL
SELECT 'products', COUNT(*) FROM product
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL
SELECT 'orders', COUNT(*) FROM customer_order
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_item
UNION ALL
SELECT 'payments', COUNT(*) FROM payment
UNION ALL
SELECT 'deliveries', COUNT(*) FROM delivery
ORDER BY table_name;


-- ============================================================
-- 7. VERIFY ORDER ITEM VARIETY
-- ============================================================

SELECT
    COUNT(*) AS total_items,
    COUNT(DISTINCT product_id) AS distinct_products,
    COUNT(DISTINCT order_id) AS orders_with_items
FROM order_item;


-- ============================================================
-- 8. VERIFY PAYMENT COUNTS AND STATUSES
-- ============================================================

SELECT
    payment_status,
    COUNT(*) AS total_payments
FROM payment
GROUP BY payment_status
ORDER BY payment_status;


-- ============================================================
-- 9. VERIFY DELIVERY RULE
-- Expected result for the current database: 0
-- ============================================================

SELECT COUNT(*) AS deliveries_with_unpaid_or_cancelled_orders
FROM delivery AS d
JOIN customer_order AS co
    ON co.order_id = d.order_id
JOIN payment AS p
    ON p.order_id = co.order_id
WHERE p.payment_status <> 'Paid'
   OR co.status = 'Cancelled';


-- ============================================================
-- 10. VIEW SAMPLE JOINED ORDER DATA
-- ============================================================

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
    oi.quantity * oi.unit_price_at_purchase AS line_total,
    pay.payment_status,
    d.delivery_status
FROM customer AS c
JOIN customer_order AS co
    ON co.customer_id = c.customer_id
JOIN order_item AS oi
    ON oi.order_id = co.order_id
JOIN product AS p
    ON p.product_id = oi.product_id
LEFT JOIN payment AS pay
    ON pay.order_id = co.order_id
LEFT JOIN delivery AS d
    ON d.order_id = co.order_id
ORDER BY co.order_id, oi.order_item_id
LIMIT 50;