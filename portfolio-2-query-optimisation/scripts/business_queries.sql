-- ============================================================
-- ShopSmart E-commerce and Inventory Management System
-- Portfolio 2: Business Queries
-- PostgreSQL
-- ============================================================

-- Query 1: Retrieve order details with customer and product
-- information, including the total value of each order item.

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