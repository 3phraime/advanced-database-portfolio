-- ShopSmart partitioning demonstration
-- PostgreSQL RANGE partitioning by order_id

CREATE TABLE customer_order_partitioned (
    order_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    order_date TIMESTAMP NOT NULL,
    status VARCHAR(30) NOT NULL,
    PRIMARY KEY (order_id)
)
PARTITION BY RANGE (order_id);

-- Partition 1: Order IDs 1 to 500
CREATE TABLE customer_order_p1
PARTITION OF customer_order_partitioned
FOR VALUES FROM (1) TO (501);

-- Partition 2: Order IDs 501 to 1000
CREATE TABLE customer_order_p2
PARTITION OF customer_order_partitioned
FOR VALUES FROM (501) TO (1001);

-- Partition 3: Order IDs 1001 to 2000
CREATE TABLE customer_order_p3
PARTITION OF customer_order_partitioned
FOR VALUES FROM (1001) TO (2001);
