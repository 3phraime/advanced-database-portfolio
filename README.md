# ShopSmart --- E-commerce and Inventory Management System

**MIT 8103 --- Advanced Database Systems**\
**Practical Database Portfolio \| First Semester, 2026/2027**\
**Student:** Ephraim Ameh \| **Student ID:** 301932136\
**Repository:** https://github.com/3phraime/advanced-database-portfolio

------------------------------------------------------------------------

## 1. Project Overview

ShopSmart is a simulated e-commerce and inventory management system used
as the common case study for this Advanced Database Systems practical
portfolio. It represents an online retailer managing customers, product
categories, products, stock levels, customer orders, order items,
payment records and delivery information.

The project investigates how database technologies support reliable
business data management: maintaining relationships and integrity,
retrieving order information efficiently, controlling concurrent
inventory updates, representing selected records as documents, and
organising operational data as it grows.

The implementation is an academic prototype. It does not include a
complete storefront, live payment gateway, delivery-provider integration
or a production multi-node PostgreSQL replication cluster.

## 2. Project Objectives

The portfolio applies five areas of advanced database practice to the
same ShopSmart scenario:

1.  **Database design and modelling:** identify entities, relationships,
    keys and constraints and implement a relational schema.
2.  **Query processing and optimisation:** develop SQL queries, inspect
    execution plans and evaluate indexes against different query
    patterns.
3.  **Transactions and concurrency:** demonstrate commit and rollback,
    examine isolation and observe visibility across database sessions.
4.  **NoSQL and advanced data models:** implement selected data in
    MongoDB Atlas, perform CRUD operations and demonstrate embedded
    documents.
5.  **Distributed and cloud databases:** demonstrate PostgreSQL
    partitioning and partition pruning, and discuss replication and
    distributed architecture.

## 3. System Scope and Business Data

The relational design covers:

-   **Customers:** identity and contact/address details.
-   **Categories:** product classification.
-   **Products:** descriptions, category association and unit prices.
-   **Inventory:** quantity on hand, reorder level and last update for
    each product.
-   **Customer orders:** customer association, order date and status.
-   **Order items:** products, quantities and purchase-time unit prices.
-   **Payments:** amount, method, status, date and transaction
    reference.
-   **Deliveries:** delivery address, status, shipment/delivery dates
    and tracking number.

The design uses primary keys, foreign keys, unique constraints and
appropriate relationships. Order totals are treated as derived values
rather than separately stored facts. The inventory model represents one
stock record per product for a single-store scenario.

## 4. Technology and Implementation Approach

  -----------------------------------------------------------------------
  Area                                Technology / approach
  ----------------------------------- -----------------------------------
  Relational database                 PostgreSQL 18.6

  Relational client                   `psql` on Windows

  Relational database                 `shopsmart`

  NoSQL platform                      MongoDB Atlas

  NoSQL database                      `shopsmart_nosql`

  NoSQL collections                   `products`, `orders`

  Source control                      GitHub

  Evidence                            Markdown READMEs, SQL/JavaScript
                                      scripts, ERD, tests, execution
                                      plans and screenshots
  -----------------------------------------------------------------------

PostgreSQL supports the relational schema, business queries, transaction
exercises and partitioning experiment. MongoDB Atlas supports the
document-oriented activity. The NoSQL implementation is a complementary
modelling exercise, not a migration of the PostgreSQL database.

## 5. Repository Structure

``` text
advanced-database-portfolio/
├── README.md
├── portfolio-1-database-design/
│   ├── erd/
│   ├── scripts/
│   ├── tests/
│   └── screenshots/
├── portfolio-2-query-optimisation/
│   ├── scripts/
│   ├── tests/
│   └── screenshots/
├── portfolio-3-transactions-concurrency/
│   ├── scripts/
│   └── screenshots/
├── portfolio-4-nosql/
│   ├── scripts/
│   └── screenshots/
└── portfolio-5-distributed-cloud/
    ├── diagrams/
    ├── scripts/
    └── screenshots/
```

The directory names identify the five activity areas. Each folder
contains its activity-specific README and supporting artifacts where
prepared. Consult the relevant folder README for its file inventory and
instructions.

## 6. Portfolio 1 --- Database Design and Modelling

### 6.1 Purpose and data model

This activity translates ShopSmart's business requirements into a
relational database design. The model contains eight entities:
`CUSTOMER`, `CATEGORY`, `PRODUCT`, `INVENTORY`, `CUSTOMER_ORDER`,
`ORDER_ITEM`, `PAYMENT` and `DELIVERY`.

The relationships include one customer to many orders; one category to
many products; one product to one inventory record in the single-store
model; one order to many order items; one product to many order-item
records; and one-to-one order relationships with payment and delivery,
implemented using unique order references.

### 6.2 Implementation and dataset

The portfolio includes an ERD, relational schema SQL, sample-data SQL
and constraint tests. The sample dataset contains 100 customers, 10
categories, 50 products, 50 inventory records, 500 orders and 1,248
order items, together with payment and delivery records.

The design uses primary keys, foreign keys, uniqueness and integrity
constraints. Derived order totals are not stored as independent facts. A
known limitation is that the basic schema does not enforce that every
order must contain at least one order item.

**Evidence:** See `portfolio-1-database-design/` for the ERD, schema and
sample-data scripts, constraint tests and screenshots.

## 7. Portfolio 2 --- Query Processing and Optimisation

### 7.1 Query and execution-plan analysis

A business query joins customer, `customer_order`, `order_item` and
product data to return order-line information. PostgreSQL
`EXPLAIN ANALYZE` was used to inspect row counts, estimated cost, plan
operators, planning time and execution time.

Indexes were tested on customer-order and order-item lookup columns. In
the observed runs, the main multi-table query continued to use
sequential scans and hash joins; the added indexes were not selected for
that workload. Separate selective lookups by `customer_id` and
`order_id` did use their relevant indexes.

### 7.2 Interpretation

The experiment demonstrates that an index is not automatically
beneficial for every query. Its usefulness depends on the predicate,
selectivity, table size and execution plan selected by PostgreSQL.
Recorded timings are individual observations on synthetic data and
should not be treated as proof of a repeatable performance improvement.

**Evidence:** See `portfolio-2-query-optimisation/` for business
queries, sample-data and index scripts, tests, execution-plan
screenshots and the activity README.

## 8. Portfolio 3 --- Transactions and Concurrency

### 8.1 Commit and rollback

The transaction exercises use the Wireless Mouse inventory record. The
commit demonstration changes stock from 50 to 45 and confirms the
committed value. A separate rollback exercise makes a temporary stock
change and reverses it, restoring the previously committed quantity.
This illustrates the difference between a change made permanent by
`COMMIT` and an uncommitted change cancelled by `ROLLBACK`.

### 8.2 Isolation and concurrent visibility

The isolation exercise uses two PostgreSQL sessions. While one session
holds an uncommitted inventory update, the other continues to see the
previously committed value under the tested Read Committed behaviour.
After the first session commits, a subsequent read in the other session
sees the new value.

This demonstrates transaction visibility and the importance of
concurrency control when multiple users or processes may update shared
stock. The exercises are educational demonstrations, not a
high-contention benchmark or a complete production locking
implementation.

**Evidence:** See `portfolio-3-transactions-concurrency/` for
transaction scripts and screenshots of inventory values, commit/rollback
behaviour and the two-session isolation exercise.

## 9. Portfolio 4 --- NoSQL and Advanced Data Models

### 9.1 MongoDB Atlas structure

MongoDB Atlas hosts the `shopsmart_nosql` database with `products` and
`orders` collections. Product documents represent items such as Wireless
Mouse, Electric Kettle and Database Systems Textbook. An order document
stores customer and order details with an embedded array of purchased
items and payment/status information.

Embedding order items keeps data commonly retrieved with an order
together in one document. This differs from the relational model, where
order items are stored in a separate table and linked by foreign keys.

### 9.2 CRUD operations and comparison

The practical work demonstrates: - **Create:** insert product documents
and an order document. - **Read:** query products, including a
category-based query. - **Update:** change the Wireless Mouse stock
quantity. - **Delete:** remove a temporary test product and verify it is
no longer returned.

The activity highlights the flexibility of document structures and the
trade-offs between embedding related data and maintaining normalised
relational records. MongoDB Atlas is the hosted NoSQL service used here;
PostgreSQL remains local.

**Evidence:** See `portfolio-4-nosql/` for the MongoDB script, activity
README and screenshots of the Atlas cluster, collections, documents and
CRUD operations.

## 10. Portfolio 5 --- Distributed and Cloud Databases

### 10.1 PostgreSQL range partitioning

A separate table named `customer_order_partitioned` was created using
range partitioning on `order_id`. Three partitions cover the ranges
1--500, 501--1000 and 1001--2000. All 500 rows from the original
`customer_order` table were copied into the partitioned table.
Verification queries checked the copied row count and distribution
across partitions.

### 10.2 Partition pruning and architecture

An `EXPLAIN` query filtering `order_id` values from 1001 to 1100 showed
access to the relevant third partition, demonstrating partition pruning.
One observed execution was faster on the partitioned table, but the
dataset is small and the measurements were individual runs; the result
is illustrative rather than conclusive evidence of a general performance
improvement.

A primary-and-replica architecture was documented as a proposed design
to explain replication and availability. The practical PostgreSQL work
is local table partitioning. A multi-server PostgreSQL replication
cluster and sharding were not deployed. Partitioning, replication and
sharding are distinct techniques.

**Evidence:** See `portfolio-5-distributed-cloud/` for partition
creation and verification scripts, the architecture diagram and
screenshots of partition distribution and query plans.

## 11. How to Review the Project

1.  Read this root README for the ShopSmart scenario, implementation
    approach and portfolio map.
2.  Open each `portfolio-*` directory and read its activity-specific
    README.
3.  Review the ERD and relational schema in Portfolio 1.
4.  Inspect business SQL, index experiments and execution-plan evidence
    in Portfolio 2.
5.  Review transaction scripts and session screenshots in Portfolio 3.
6.  Inspect MongoDB scripts and Atlas CRUD evidence in Portfolio 4.
7.  Review partition scripts, verification output and proposed
    architecture in Portfolio 5.

The SQL and JavaScript files are practical learning artifacts. Review
comments and prerequisites before rerunning scripts that create objects
or insert records. Some setup scripts are intended for an initial run
and may create duplicate data or objects if rerun without resetting the
environment.

## 12. Limitations and Future Improvements

The project uses synthetic data. Query timings are individual
observations and would require repeated, controlled benchmarking with
larger datasets before stronger performance conclusions could be made.
The relational schema could be extended with additional business rules,
including enforcement that an order must contain at least one item. A
future implementation could deploy PostgreSQL replication across
separate servers, evaluate failover and investigate sharding if data
volume and workload justify it.

The prototype does not implement a production storefront, real payment
processing, delivery-provider integration or a live distributed
PostgreSQL service.

## 13. Academic Integrity and AI Assistance

This is an individual academic portfolio. ChatGPT by OpenAI was used as
a learning and drafting aid to explain database concepts, help structure
SQL experiments and documentation, and interpret selected query-plan and
transaction observations. The student is responsible for understanding
and verifying the submitted work. Suggestions were reviewed against the
PostgreSQL and MongoDB environments, and descriptions were adjusted to
reflect observed outputs and implementation limits. Scripts, screenshots
and database outputs---not AI-generated statements---serve as the
practical evidence.

### Technical references

-   PostgreSQL Documentation: https://www.postgresql.org/docs/
-   MongoDB Manual: https://www.mongodb.com/docs/manual/
-   MongoDB Atlas Documentation: https://www.mongodb.com/docs/atlas/

------------------------------------------------------------------------

**Repository:** https://github.com/3phraime/advanced-database-portfolio
