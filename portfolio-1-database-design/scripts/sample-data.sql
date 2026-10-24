
-- ShopSmart sample data

INSERT INTO category (category_name, description)
VALUES
    ('Electronics', 'Electronic devices and accessories'),
    ('Home and Kitchen', 'Products for home and kitchen use'),
    ('Books', 'Books and educational materials');

INSERT INTO customer (
    first_name, last_name, email, phone,
    address_line1, city, postal_code
)
VALUES
    ('Amara', 'Okafor', 'amara.okafor@gmail.com',
     '08030000001', '12 Market Road', 'Abuja', '900001'),
    ('Daniel', 'Bello', 'daniel.bello@hotmail.com',
     '08030000002', '25 Garden Street', 'Lagos', '100001'),
    ('Fatima', 'Yusuf', 'fatima.yusuf@gmail.com',
     '08030000003', '8 River Lane', 'Kano', '700001');

INSERT INTO product (
    category_id, product_name, description, unit_price, active
)
VALUES
    (1, 'Wireless Mouse', 'Wireless USB computer mouse', 8500.00, TRUE),
    (2, 'Electric Kettle', '1.7 litre electric kettle', 18500.00, TRUE),
    (3, 'Database Systems Textbook', 'Textbook for database studies', 12000.00, TRUE);

INSERT INTO inventory (
    product_id, quantity_on_hand, reorder_level
)
VALUES
    (1, 50, 10),
    (2, 30, 5),
    (3, 40, 8);

INSERT INTO customer_order (customer_id, status)
VALUES
    (1, 'Pending'),
    (2, 'Processing');

INSERT INTO order_item (
    order_id, product_id, quantity, unit_price_at_purchase
)
VALUES
    (1, 1, 2, 8500.00),
    (1, 2, 1, 18500.00),
    (2, 3, 2, 12000.00);

INSERT INTO payment (
    order_id, amount, payment_method, payment_status,
    payment_date, transaction_reference
)
VALUES
    (1, 35500.00, 'Card', 'Paid',
     CURRENT_TIMESTAMP, 'TXN-SM-1001'),
    (2, 24000.00, 'Bank Transfer', 'Pending',
     NULL, 'TXN-SM-1002');

INSERT INTO delivery (
    order_id, delivery_address, delivery_status,
    shipped_date, delivered_date, tracking_number
)
VALUES
    (1, '12 Market Road, Abuja, 900001', 'Shipped',
     CURRENT_TIMESTAMP, NULL, 'SM-TRK-1001'),
    (2, '25 Garden Street, Lagos, 100001', 'Pending',
     NULL, NULL, 'SM-TRK-1002');
