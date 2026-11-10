# Portfolio 2: Query Processing and Optimisation

## 1. Objective

This portfolio investigates how PostgreSQL processes business queries and how indexes influence query execution. Using the ShopSmart E-commerce and Inventory Management System, the exercise examines multi-table joins, execution plans, index usage, and query performance.

The practical work uses `EXPLAIN (ANALYZE, BUFFERS)` to inspect PostgreSQL's chosen execution strategies and compare the full business query with targeted queries that filter records.

## 2. Sample Data Expansion and Rationale

### 2.1 Why Additional Sample Data Was Generated

The initial ShopSmart database contained only a small number of records. Although the original data was sufficient to verify the relational schema and demonstrate basic SQL joins, it provided limited scope for investigating query processing and optimisation.

Additional fictional sample data was therefore generated to create a more representative e-commerce dataset and provide more records for examining PostgreSQL execution plans.

The expanded dataset contains:

| Table | Number of records |
|---|---:|
| Customers | 100 |
| Categories | 10 |
| Products | 50 |
| Inventory | 50 |
| Customer orders | 500 |
| Order items | 1,248 |
| Payments | 500 |
| Deliveries | 133 |

### 2.2 How the Additional Data Supports the Experiment

The expanded dataset supports three main objectives:

1. **Multi-table join analysis:** The business query combines customer, order, order-item, and product information, producing 1,248 result rows.
2. **Index evaluation:** The additional records allow targeted queries to be tested using indexes on customer and order identifiers.
3. **Execution-plan analysis:** PostgreSQL's execution plans provide information about scan types, join strategies, sorting, estimated costs, buffer activity, and recorded execution times.

The data is synthetic and was created for academic testing. It does not represent actual customers or transactions.

### 2.3 Data Generation and Verification

The data-generation workflow and verification queries are documented in `scripts/generate_sample_data.sql`. These queries were used to inspect table counts, order-item variety, payment statuses, and whether deliveries were associated with unpaid or cancelled orders.

The expanded dataset was retained throughout the optimisation experiments so that the query plans could be compared against the same underlying data.

**Important:** The generation script documents insert, update, and verification operations. It should not be rerun against the populated database without first preparing a clean schema, because doing so may alter or duplicate data.

## 3. Business Query

**Evidence:** `screenshots/01_business-query-output.png`

The business query joins four tables:

- `customer`
- `customer_order`
- `order_item`
- `product`

It retrieves customer names, order identifiers and dates, order status, product names, quantities, purchase prices, and calculated line totals.

The line total is calculated using:

`quantity * unit_price_at_purchase`

The query uses inner joins to combine related records through their primary-key and foreign-key relationships. The results are ordered by order ID and order-item ID to make the output easier to inspect.

The query returned 1,248 rows from the expanded dataset. This demonstrates how relational joins combine information stored across multiple tables into a single business report.

## 4. Baseline Execution Plan

**Evidence:** `screenshots/02_baseline-execution-plan.png`

The baseline execution plan was captured using `EXPLAIN (ANALYZE, BUFFERS)` before the two additional indexes were created.

The query returned 1,248 rows and recorded an execution time of **2.917 ms**. PostgreSQL used sequential scans and hash joins to process the participating tables, followed by a sort operation.

A sequential scan reads rows directly from a table. A hash join uses a hash structure to match rows between tables. These strategies can be appropriate when a query needs to process a substantial proportion of the available data.

The baseline provides a reference point for examining the execution plans after indexes were added.

## 5. Execution Plan After Adding the Customer Index

**Evidence:** `screenshots/03_after-customer-index.png`

An index named `idx_customer_order_customer_id` was created on `customer_order.customer_id`.

After adding the index, the full business query returned the same 1,248 rows and recorded an execution time of **2.640 ms**.

However, PostgreSQL continued to use sequential scans and hash joins for the full query rather than using the new customer index.

This demonstrates that creating an index does not guarantee that PostgreSQL will use it for every query. The query planner selects an execution strategy based on estimated costs and the requirements of the query.

The difference between the baseline and this recorded execution time does not, by itself, establish that the index improved performance.

## 6. Execution Plan After Adding the Order-Item Index

**Evidence:** `screenshots/04_after-order-item-index.png`

A second index named `idx_order_item_order_id` was created on `order_item.order_id`.

After adding this index, the full business query continued to return 1,248 rows. The recorded execution time was **4.215 ms**.

The execution plan still used sequential scans and hash joins for the full-result query rather than using either of the two new indexes.

The higher recorded time in this run does not prove that the index caused a slowdown. Execution times can vary between runs due to factors such as caching and system activity. The main observation is that PostgreSQL did not select either new index for this query.

## 7. Targeted Customer Query Using an Index

**Evidence:** `screenshots/05_customer-filter-index-plan.png`

A targeted query was executed against `customer_order`, filtering records with `customer_id = 73`.

The execution plan used a **bitmap index scan** on `idx_customer_order_customer_id`, followed by a **bitmap heap scan** to retrieve the matching table rows.

The query returned five rows and recorded an execution time of **1.299 ms**.

This result demonstrates that the customer index can be useful for a selective query that retrieves orders belonging to a particular customer. Rather than processing the full order table in the same way as the business query, PostgreSQL used the index to help locate matching records.

## 8. Targeted Order-Item Query Using an Index

**Evidence:** `screenshots/06_order-item-index-scan.png`

A targeted query was executed against `order_item`, filtering records with `order_id = 1486`.

PostgreSQL used an **index scan** on `idx_order_item_order_id` and returned two rows. The recorded execution time was **0.342 ms**.

This demonstrates how an index can help PostgreSQL locate order items associated with a particular order. The execution plan provides direct evidence that the order-item index was selected for this targeted query.

## 9. Overall Performance Analysis and Findings

The experiment demonstrates that PostgreSQL's query-planning decisions depend on the query being executed.

The main findings are:

- The full business query returned 1,248 rows using sequential scans, hash joins, and sorting.
- The customer index was not selected for the full business query but was used for the targeted customer filter.
- The order-item index was not selected for the full business query but was used for the targeted order-item filter.
- The query returned the same number of rows before and after the indexes were added, indicating that the indexes did not change the intended query results.
- Recorded execution times varied between runs, so timing differences alone are insufficient to establish a performance improvement or slowdown.

The results suggest that indexes can be useful when queries retrieve a relatively small subset of records. For queries that process a large proportion of a table, PostgreSQL may choose sequential scans and hash joins instead.

The dataset is suitable for demonstrating these query-planning behaviours, but it remains a small academic dataset. The results should not be interpreted as proof of performance at large production scale.

## 10. Reproducibility

The Portfolio 2 files are organised as follows:

- `scripts/business_queries.sql` — contains the main business query.
- `scripts/business_queries.sql` — check whether this file contains the same or additional queries; retain only the appropriate files and document their purpose accurately.
- `scripts/generate_sample_data.sql` — documents sample-data generation and verification.
- `screenshots/` — contains the business query output and execution-plan evidence.

To reproduce the query-optimisation experiment:

1. Prepare a database containing the ShopSmart schema and sample data.
2. Run the business query before creating the two additional indexes.
3. Capture its execution plan using `EXPLAIN (ANALYZE, BUFFERS)`.
4. Create the customer index and rerun the business query.
5. Create the order-item index and rerun the business query.
6. Execute the two targeted filter queries and inspect their execution plans.
7. Compare the scan types, join strategies, row counts, buffer activity, and recorded execution times.

The experiments should use the same dataset when comparing plans. The data-generation script should not be rerun against the existing populated database without first preparing a clean environment.

## 11. Conclusion

This portfolio demonstrates practical use of PostgreSQL execution plans to investigate query processing and index selection. The full business query used sequential scans and hash joins, while the targeted customer and order-item queries used the relevant indexes.

The experiment reinforces that effective query optimisation requires examining execution plans and query requirements rather than assuming that adding indexes will improve every query. The results also illustrate the importance of documenting the dataset, test conditions, and observed evidence when evaluating database performance.
