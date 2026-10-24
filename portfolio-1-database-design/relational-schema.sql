
-- ============================================================
-- ShopSmart E-commerce and Inventory Management System
-- File: relational-schema.sql
-- Purpose: Define the relational database schema
-- DBMS: PostgreSQL
-- ============================================================

-- 1. CUSTOMER
CREATE TABLE customer (
    customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(30),
    address_line1 VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20)
);

-- 2. CATEGORY
CREATE TABLE category (
    category_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- 3. PRODUCT
CREATE TABLE product (
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id INTEGER NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    description TEXT,
    unit_price NUMERIC(10, 2) NOT NULL
        CHECK (unit_price > 0),
    active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES category(category_id)
);

-- 4. INVENTORY
CREATE TABLE inventory (
    inventory_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id INTEGER NOT NULL UNIQUE,
    quantity_on_hand INTEGER NOT NULL DEFAULT 0
        CHECK (quantity_on_hand >= 0),
    reorder_level INTEGER NOT NULL DEFAULT 5
        CHECK (reorder_level >= 0),
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id)
        REFERENCES product(product_id)
);

-- 5. CUSTOMER_ORDER
CREATE TABLE customer_order (
    order_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',

    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
);

-- 6. ORDER_ITEM
CREATE TABLE order_item (
    order_item_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL
        CHECK (quantity > 0),
    unit_price_at_purchase NUMERIC(10, 2) NOT NULL
        CHECK (unit_price_at_purchase > 0),

    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id)
        REFERENCES customer_order(order_id),

    CONSTRAINT fk_order_item_product
        FOREIGN KEY (product_id)
        REFERENCES product(product_id)
);

-- 7. PAYMENT
CREATE TABLE payment (
    payment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE,
    amount NUMERIC(10, 2) NOT NULL
        CHECK (amount >= 0),
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    payment_date TIMESTAMP,
    transaction_reference VARCHAR(100),

    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES customer_order(order_id)
);

-- 8. DELIVERY
CREATE TABLE delivery (
    delivery_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE,
    delivery_address VARCHAR(255) NOT NULL,
    delivery_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    shipped_date TIMESTAMP,
    delivered_date TIMESTAMP,
    tracking_number VARCHAR(100),

    CONSTRAINT fk_delivery_order
        FOREIGN KEY (order_id)
        REFERENCES customer_order(order_id)
);
