-- ShopSmart partition verification

-- 1. Confirm the total number of partitioned orders
SELECT COUNT(*) AS total_partitioned_orders
FROM customer_order_partitioned;

-- 2. Show how orders are distributed
-- across the three partitions
SELECT
    tableoid::regclass AS partition_name,
    COUNT(*) AS number_of_orders
FROM customer_order_partitioned
GROUP BY tableoid
ORDER BY partition_name;

-- 3. Demonstrate partition pruning
EXPLAIN
SELECT *
FROM customer_order_partitioned
WHERE order_id BETWEEN 1001 AND 1100;

-- 4. Inspect the partition hierarchy
SELECT
    parent.relname AS partitioned_table,
    child.relname AS partition_name
FROM pg_inherits
JOIN pg_class parent
    ON pg_inherits.inhparent = parent.oid
JOIN pg_class child
    ON pg_inherits.inhrelid = child.oid
WHERE parent.relname = 'customer_order_partitioned'
ORDER BY child.relname;
