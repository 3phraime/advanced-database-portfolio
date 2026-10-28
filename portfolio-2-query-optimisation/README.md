# Portfolio 2 — Query Processing and Optimisation

**Case study:** ShopSmart E-commerce and Inventory Management System

## Performance Analysis

The baseline execution plan for the four-table business query returned 1,248 rows, with an execution time of 2.917 ms. PostgreSQL used sequential scans and hash joins to combine the customer, customer_order, order_item, and product tables.

After creating an index on `customer_order.customer_id`, the full query completed in 2.640 ms. However, PostgreSQL continued to use sequential scans and hash joins because the query retrieves a large portion of the tables. After adding an index on `order_item.order_id`, the full query took 4.215 ms in the recorded run, and the execution plan still did not use either new index for the full join.

Targeted queries demonstrated that the indexes can be useful for selective searches. The customer filter used a bitmap index scan, while the order-item filter used an index scan on `idx_order_item_order_id`.

These results show that indexes are not automatically beneficial for every query. PostgreSQL's query planner chooses a plan based on estimated cost and the query's requirements. The recorded execution times vary between runs, so the measurements alone do not establish that an index caused a performance improvement. The execution plans provide stronger evidence of when the indexes were used.