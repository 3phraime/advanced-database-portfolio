# Portfolio 5: Distributed and Cloud Database Exercise
 
**Database Platform:** PostgreSQL 18.6  
**Environment:** Windows 64-bit  
**Database:** `shopsmart`

## 1. Introduction

This portfolio explores distributed database concepts using the ShopSmart E-commerce and Inventory Management System developed in the previous portfolios.

The exercise focuses on database partitioning, query execution, replication, sharding, availability, consistency and cloud database deployment.

PostgreSQL was used for the practical partitioning demonstration. The existing ShopSmart database was retained, and a separate partitioned demonstration table was created to avoid modifying the original order table and its relationships.

## 2. Database Environment

The practical exercise used the following environment:

| Property | Description |
|---|---|
| Database system | PostgreSQL |
| Version | 18.6 |
| Operating system | Windows 64-bit |
| Database name | shopsmart |
| Original order table | customer_order |
| Original number of orders | 500 |

The original `customer_order` table contains order identifiers, customer identifiers, order dates and order statuses.

The order IDs ranged from 1 to 1496, while the order dates ranged from 28 October 2025 to 26 October 2026.

## 3. Table Partitioning Implementation

### 3.1 Partitioning approach

Range partitioning was selected for the practical exercise.

A separate table named `customer_order_partitioned` was created using PostgreSQL's RANGE partitioning feature, with `order_id` as the partition key.

Three partitions were created:

| Partition | Order ID range |
|---|---|
| customer_order_p1 | 1–500 |
| customer_order_p2 | 501–1000 |
| customer_order_p3 | 1001–2000 |

The original `customer_order` table was not modified. Its records were copied into the new partitioned demonstration table.

### 3.2 Data migration and verification

All 500 existing order records were successfully copied into the partitioned table.

The following query was used to verify the number of records:

```sql
SELECT COUNT(*) AS partitioned_order_count
FROM customer_order_partitioned;
```

The result was 500 records, confirming that all existing orders were copied successfully.

### 3.3 Distribution of records

The following query was used to examine the number of records stored in each partition:

```sql
SELECT
    tableoid::regclass AS partition_name,
    COUNT(*) AS number_of_orders
FROM customer_order_partitioned
GROUP BY tableoid
ORDER BY partition_name;
```

The results were:

| Partition | Number of orders |
|---|---:|
| customer_order_p1 | 2 |
| customer_order_p2 | 2 |
| customer_order_p3 | 496 |
| **Total** | **500** |

The distribution shows that most of the existing order IDs fall within the third partition.

This demonstrates the importance of selecting appropriate partition boundaries based on actual data distribution. Uneven partition sizes can reduce the effectiveness of partitioning.

## 4. Partition Pruning

Partition pruning allows PostgreSQL to exclude partitions that cannot contain records matching a query condition.

The following query was executed:

```sql
EXPLAIN
SELECT *
FROM customer_order_partitioned
WHERE order_id BETWEEN 1001 AND 1100;
```

The execution plan showed:

```text
Index Scan using customer_order_p3_pkey
on customer_order_p3
```

PostgreSQL accessed `customer_order_p3` and excluded the other two partitions.

This demonstrates partition pruning and shows how suitable partition-key conditions can reduce unnecessary data access.

## 5. Query Performance Comparison

The original and partitioned tables were compared using `EXPLAIN ANALYZE`.

Both queries retrieved orders with IDs between 1001 and 1100.

### 5.1 Original table query

```sql
EXPLAIN ANALYZE
SELECT *
FROM customer_order
WHERE order_id BETWEEN 1001 AND 1100;
```

Observed execution time: **2.125 ms**

### 5.2 Partitioned table query

```sql
EXPLAIN ANALYZE
SELECT *
FROM customer_order_partitioned
WHERE order_id BETWEEN 1001 AND 1100;
```

Observed execution time: **0.075 ms**

### 5.3 Performance results

| Metric | Original table | Partitioned table |
|---|---:|---:|
| Rows returned | 100 | 100 |
| Execution time | 2.125 ms | 0.075 ms |
| Planning time | 10.944 ms | 1.963 ms |
| Scan method | Index Scan | Index Scan |
| Partitions accessed | Not applicable | 1 |

The partitioned query recorded a lower execution time in this particular test.

The observed reduction was approximately 96.5%.

However, the dataset contained only 500 records, and the comparison was based on individual executions. Caching and other database activity can affect execution time. Therefore, the result should not be treated as proof that partitioning always improves performance.

Further testing with larger datasets and repeated executions would be necessary for a more reliable performance evaluation.

## 6. Distributed Database Architecture

A proposed distributed architecture was designed for the ShopSmart system to illustrate how multiple database nodes could support database operations.

The proposed architecture contains:

- A ShopSmart application.
- A primary PostgreSQL database server.
- Two read replicas.
- A partitioned order table.
- A replication stream using PostgreSQL Write-Ahead Logging (WAL).

The primary server handles database write operations, while read replicas can serve suitable read requests.

Changes recorded by the primary can be transferred to standby servers through PostgreSQL replication.

**Important implementation distinction:** The architecture is a proposed design. The practical exercise implemented PostgreSQL table partitioning on one local server; it did not deploy multiple database servers or configure actual replication.

## 7. Replication

Replication involves maintaining copies of database information across multiple database servers.

In the proposed ShopSmart architecture, the primary PostgreSQL server would process transactions and transmit changes to standby servers using WAL-based replication.

Two common replication approaches are:

**Synchronous replication**

The primary can wait for confirmation from a standby server before considering a transaction committed according to the configured synchronous commit policy.

This can provide stronger durability guarantees but may increase transaction latency.

**Asynchronous replication**

The primary does not wait for standby confirmation before completing each transaction.

This can improve responsiveness, but replicas may temporarily contain older data.

For ShopSmart, replication could improve read capacity and provide standby databases for recovery purposes.

## 8. Sharding and Partitioning

Partitioning and sharding are related concepts, but they are not identical.

**Partitioning** divides a table into smaller parts. In this project, PostgreSQL range partitioning was implemented using `order_id`.

**Sharding** distributes data across multiple database servers or nodes. Each server stores a portion of the overall dataset.

For a larger ShopSmart deployment, orders could potentially be distributed across different database nodes based on customer region or another suitable shard key.

This could distribute storage and query workloads across multiple servers.

Actual multi-server sharding was not implemented in this exercise. The practical work demonstrates partitioning on a single PostgreSQL server.

## 9. Availability and Consistency

### 9.1 Availability

Availability refers to the ability of a database system to remain accessible when failures occur.

In the proposed ShopSmart architecture, standby replicas could support recovery if the primary database becomes unavailable.

However, replication alone does not guarantee automatic failover. Additional monitoring, failover management and recovery procedures would be required.

### 9.2 Consistency

Consistency ensures that database operations maintain correct and reliable information.

For ShopSmart, consistency is important when handling:

- Customer orders.
- Product stock quantities.
- Payment statuses.
- Order delivery statuses.

For example, a successful payment should not be reflected as an unpaid order in another part of the system.

Asynchronous replication can introduce temporary replication lag. Therefore, critical operations such as payment confirmation and stock updates should use appropriate transaction and consistency controls.

## 10. Cloud Database Deployment

Cloud database deployment involves hosting database services on cloud infrastructure rather than relying entirely on locally managed database servers.

A cloud-hosted ShopSmart database could provide:

- Managed database infrastructure.
- Remote database access.
- Backup and recovery services.
- Monitoring and resource management.
- Opportunities for replication and availability configurations.

MongoDB Atlas was used in Portfolio 4 to demonstrate a managed cloud-hosted database environment for the ShopSmart NoSQL implementation.

For the PostgreSQL implementation in this portfolio, the database remained locally hosted on Windows. A managed cloud PostgreSQL deployment is a proposed extension rather than an implemented deployment.

## 11. Limitations and Future Improvements

The practical exercise demonstrated table partitioning and partition pruning using the existing ShopSmart order dataset.

The following limitations were identified:

1. The demonstration used a relatively small dataset of 500 orders.
2. The three partitions contained an uneven distribution of records.
3. Query performance was compared using individual executions rather than repeated benchmark tests.
4. Actual replication between PostgreSQL servers was not configured.
5. Multi-server sharding was discussed but not implemented.
6. PostgreSQL cloud deployment was proposed but not performed.

Future improvements could include testing with a much larger dataset, selecting better partition boundaries, configuring PostgreSQL streaming replication and deploying the database on managed cloud infrastructure.

## 12. Conclusion

This portfolio demonstrated PostgreSQL range partitioning using the ShopSmart E-commerce and Inventory Management System.

A separate partitioned order table was created, and all 500 existing orders were copied into three partitions. Partition distribution was verified, and an execution plan demonstrated partition pruning.

A performance comparison was also conducted between the original and partitioned tables. The partitioned query recorded a lower execution time in the observed test.

The exercise also explored distributed database architecture, replication, sharding, availability, consistency and cloud deployment.

Overall, the practical work improved understanding of how partitioning can organise database records and how distributed database techniques can support larger, more available database systems.

## 13. Project Files and Evidence

The supporting files are organised as follows:

```text
portfolio-5-distributed-cloud/
│
├── README.md
│
├── diagrams/
│   └── 08_shopsmart_distributed_architecture.png
│
├── screenshots/
│   ├── 01_postgresql_environment.png
│   ├── 02_order_partitions_created.png
│   ├── 03_orders_copied_to_partitions.png
│   ├── 04_order_distribution.png
│   ├── 05_partition_pruning_explain.png
│   ├── 06_original_table_query_plan.png
│   ├── 07_partitioned_table_query_plan.png
│   └── 08_shopsmart_distributed_architecture.png
│
└── scripts/
    ├── 01_create_order_partitions.sql
    └── 02_partition_verification.sql
```

The SQL scripts document the partition creation and verification process. The screenshots provide evidence of the PostgreSQL environment, partition creation, data migration, partition distribution, query execution plans and proposed architecture.

## 14. Personal Reflection

This exercise provided practical experience with PostgreSQL table partitioning and query execution plans.

I learned how PostgreSQL can organise a large table into smaller partitions and how partition pruning can reduce unnecessary data access.

The exercise also improved my understanding of the differences between partitioning, sharding and replication, as well as the importance of availability and consistency in distributed database systems.

The comparison between the original and partitioned order tables demonstrated the importance of measuring database performance rather than assuming that a particular design will always be faster.