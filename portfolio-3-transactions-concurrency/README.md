# Portfolio 3: Transactions and Concurrency

## 1. Introduction and Objective

This portfolio investigates transaction management, transaction isolation, and concurrency control in PostgreSQL using the ShopSmart E-commerce and Inventory Management System.

The practical exercises use the existing `inventory` table to demonstrate how database transactions manage stock updates, how uncommitted changes are handled, and how PostgreSQL manages simultaneous access to the same inventory record.

The main objectives are to:

- Demonstrate transaction control using `COMMIT` and `ROLLBACK`.
- Examine PostgreSQL's `READ COMMITTED` transaction isolation level.
- Investigate how two database sessions interact when accessing the same record.
- Demonstrate how PostgreSQL row-level locking prevents conflicting updates from executing simultaneously.

## 2. Transaction Management: COMMIT and ROLLBACK

### 2.1 COMMIT Operation

**Evidence:**
- `screenshots/01_inventory_level_before_commit.png`
- `screenshots/02_commit-script.png`
- `screenshots/03_inventory_level_after_commit.png`

The first exercise demonstrated how PostgreSQL saves changes made within a transaction.

The existing `inventory` table was used instead of creating a separate permanent table. Product ID 1 initially had 50 units in stock.

A transaction was started using `BEGIN`, and the stock quantity was reduced from 50 to 45. The updated value was checked before the transaction was committed.

The `COMMIT` command successfully saved the change. A subsequent SELECT query confirmed that the inventory quantity remained at 45.

This demonstrates that COMMIT permanently saves the changes made within a transaction.

### 2.2 ROLLBACK Operation

**Evidence:**
- `screenshots/04_inventory_level_before_rollback.png`
- `screenshots/05_inventory_level_after_rollback.png`

The second exercise demonstrated how PostgreSQL reverses uncommitted changes.

Starting with the committed stock quantity of 45 units, a new transaction was started. The inventory quantity was temporarily reduced to 35.

The change was inspected within the active transaction before executing `ROLLBACK`.

After the rollback, another SELECT query confirmed that the stock quantity had returned to 45.

This demonstrates that ROLLBACK reverses changes made within an active transaction that have not yet been committed.

The exercise also highlighted the importance of executing `BEGIN` before making changes when a rollback demonstration is required. PostgreSQL's default autocommit behaviour saves standalone statements automatically.

## 3. Transaction Isolation

### 3.1 Isolation Level Identification

PostgreSQL's transaction isolation level was checked in two separate database sessions using:

`SHOW transaction_isolation;`

Both sessions returned:

`read committed`

This confirmed that the database was using PostgreSQL's default READ COMMITTED isolation level.

### 3.2 Testing READ COMMITTED Behaviour

**Evidence:**
- `screenshots/06_transaction_isolation_before_commit.png`
- `screenshots/07_transaction_isolation_after_commit.png`

Two separate PostgreSQL sessions were opened and connected to the same ShopSmart database.

In Session 1, a transaction was started and the stock quantity for product ID 1 was updated from 45 to 30. The transaction was deliberately left uncommitted.

Session 2 queried the same inventory record and continued to see the previously committed quantity of 45.

This demonstrated that Session 2 could not see Session 1's uncommitted changes.

Session 1 was then committed. When Session 2 executed the SELECT statement again, it could see the updated quantity of 30.

This demonstrates READ COMMITTED behaviour: a transaction cannot read another transaction's uncommitted changes, but subsequent statements can see changes committed by other transactions.

## 4. Concurrency and Row-Level Locking

### 4.1 Concurrent Inventory Updates

**Evidence:**
- `screenshots/08_transaction_concurrency.png`

The concurrency experiment used two PostgreSQL sessions to simulate two users attempting to update the same ShopSmart inventory record.

Both sessions accessed product ID 1. Session 1 started a transaction and updated the inventory record. Before Session 1 completed, Session 2 attempted to update the same record.

PostgreSQL made Session 2 wait because Session 1 held a row-level lock on the inventory record.

After Session 1 completed its transaction, Session 2 was able to continue.

This demonstrates PostgreSQL's automatic row-level locking during UPDATE operations. The database coordinates competing transactions so that conflicting updates to the same row do not execute simultaneously.

### 4.2 Concurrency Control Findings

The experiment demonstrated that:

- Multiple database sessions can access the same database simultaneously.
- An UPDATE operation acquires a row-level lock on the affected record.
- Another transaction attempting to update the locked row must wait.
- Committing the first transaction releases its lock.
- The waiting transaction can then continue.

This behaviour helps maintain database consistency when multiple users attempt to modify shared inventory records.

## 5. SQL Scripts and Evidence Organisation

The practical SQL scripts are stored in the `scripts/` directory.

| File | Purpose |
|---|---|
| `01_commit_rollback.sql` | Demonstrates transaction commits and rollbacks. |
| `02_transaction_isolation.sql` | Documents the READ COMMITTED isolation experiment. |
| `03_concurrency_control.sql` | Documents concurrent inventory updates across two sessions. |

The `screenshots/` directory contains the practical evidence for the transaction, isolation, and concurrency exercises.

The concurrency and isolation exercises require two separate PostgreSQL sessions. Their SQL statements must be executed in the appropriate session and in the documented order rather than running the entire script in one terminal.

## 6. Conclusion

This portfolio demonstrates practical transaction management and concurrency control using PostgreSQL and the ShopSmart inventory system.

The COMMIT and ROLLBACK exercises showed how database changes can be saved or reversed. The READ COMMITTED experiment demonstrated that uncommitted changes remain invisible to other sessions until committed.

The concurrency experiment demonstrated PostgreSQL's row-level locking behaviour when two sessions attempt to update the same inventory record.

Overall, the exercises illustrate the importance of transaction management, isolation, and concurrency control in maintaining reliable and consistent inventory data in a multi-user database system.

## 7. Reproducibility and Safety Notes

The experiments were conducted using the existing ShopSmart database and its inventory records.

The SQL scripts document the operations performed. Some scripts require separate PostgreSQL sessions and must not be executed from beginning to end in a single session.

The concurrency exercises changed the stock quantity of product ID 1 during testing. The final inventory quantity should be verified independently before any further testing or submission.

The existing database and sample data should not be recreated merely to reproduce these exercises. Use a separate test database if a completely fresh experiment is required.