# Portfolio 1: Database Design and Modelling

## 1. Entity-Relationship Diagram (ERD)

The ShopSmart database is modelled using eight entities: `CUSTOMER`, `CATEGORY`, `PRODUCT`, `INVENTORY`, `CUSTOMER_ORDER`, `ORDER_ITEM`, `PAYMENT`, and `DELIVERY`.

The ERD identifies the attributes stored by each entity, its primary key, foreign keys, and the relationships between entities. It provides the blueprint for the relational schema that will be implemented in PostgreSQL.

### ERD files

- `Shopsmart ERD.png` — visual preview of the database design.
- `Shopsmart ERD.drawio.png` — diagram export that can be reopened and edited in draw.io.

## 2. Entity and Relational Structure

### CUSTOMER

Stores customer contact and address information.

- **Primary key:** `customer_id`
- **Unique attribute:** `email`
- **Main attributes:** `first_name`, `last_name`, `email`, `phone`, `address_line1`, `city`, `postal_code`

The customer ID uniquely identifies each customer. Email is unique to prevent duplicate email addresses across customer records.

### CATEGORY

Stores product categories.

- **Primary key:** `category_id`
- **Unique attribute:** `category_name`
- **Other attribute:** `description`

A separate category entity allows multiple products to share a category without repeatedly storing the category's details in the product table.

### PRODUCT

Stores product information and current selling prices.

- **Primary key:** `product_id`
- **Foreign key:** `category_id` references `CATEGORY.category_id`
- **Main attributes:** `product_name`, `description`, `unit_price`, `active`

Each product belongs to one category. The foreign key ensures that a product cannot reference a category that does not exist.

### INVENTORY

Stores the current stock information for each product.

- **Primary key:** `inventory_id`
- **Foreign key and unique attribute:** `product_id`
- **Other attributes:** `quantity_on_hand`, `reorder_level`, `last_updated`

ShopSmart uses a single inventory location. The unique constraint on `product_id` prevents a product from having multiple inventory records.

The foreign key and uniqueness constraint enforce at most one inventory record per product. They do not independently guarantee that every product has an inventory record.

### CUSTOMER_ORDER

Stores the main details of customer orders.

- **Primary key:** `order_id`
- **Foreign key:** `customer_id` references `CUSTOMER.customer_id`
- **Other attributes:** `order_date`, `status`

Each order belongs to one customer. A customer may place multiple orders, so `customer_id` is not unique in this table.

### ORDER_ITEM

Stores the individual product lines within an order.

- **Primary key:** `order_item_id`
- **Foreign keys:** `order_id` references `CUSTOMER_ORDER.order_id`; `product_id` references `PRODUCT.product_id`
- **Other attributes:** `quantity`, `unit_price_at_purchase`

An order item identifies a particular product within an order. The separate `order_item_id` allows an order to contain multiple rows.

The purchase price is stored in `ORDER_ITEM` to preserve the price at the time of purchase, even if the product's current price changes later.

### PAYMENT

Stores payment information associated with orders.

- **Primary key:** `payment_id`
- **Foreign key and unique attribute:** `order_id`
- **Other attributes:** `amount`, `payment_method`, `payment_status`, `payment_date`

The unique constraint on `order_id` allows at most one payment record per order, reflecting the project's chosen business rule.

### DELIVERY

Stores delivery information associated with orders.

- **Primary key:** `delivery_id`
- **Foreign key and unique attribute:** `order_id`
- **Other attributes:** `delivery_address`, `delivery_status`, `shipped_date`, `delivered_date`

The unique constraint on `order_id` allows at most one delivery record per order. Shipment and delivery dates may be empty until the relevant events occur.

## 3. Relationships and Cardinality

The ERD uses Crow's Foot-style notation to represent relationship cardinality.

| Relationship | Cardinality | Explanation |
|---|---|---|
| CUSTOMER — CUSTOMER_ORDER | 1:M | A customer can place zero or many orders; each order belongs to one customer. |
| CATEGORY — PRODUCT | 1:M | A category can contain zero or many products; each product belongs to one category. |
| PRODUCT — INVENTORY | 1:1, intended | Each product is intended to have one inventory record, and each inventory record belongs to one product. |
| CUSTOMER_ORDER — ORDER_ITEM | 1:M | Each order contains one or more order items; each item belongs to one order. |
| PRODUCT — ORDER_ITEM | 1:M | A product can appear in many order items over time; each item references one product. |
| CUSTOMER_ORDER — PAYMENT | 1:1, intended | Each order is intended to have one payment record. |
| CUSTOMER_ORDER — DELIVERY | 1:1, intended | Each order is intended to have one delivery record. |

The distinction between an intended relationship and an enforced constraint is important. A unique foreign key prevents multiple child records from referencing the same parent, but it does not guarantee that every parent has a child record.

## 4. Keys and Integrity Constraints

### Primary keys

Each entity has a primary key that uniquely identifies its rows. Examples include `customer_id`, `product_id`, `order_id`, and `order_item_id`.

### Foreign keys

Foreign keys connect related entities and maintain referential integrity. For example, `CUSTOMER_ORDER.customer_id` references an existing customer, while `ORDER_ITEM.product_id` references an existing product.

### Unique constraints

The design uses uniqueness constraints on:

- `CUSTOMER.email`
- `CATEGORY.category_name`
- `INVENTORY.product_id`
- `PAYMENT.order_id`
- `DELIVERY.order_id`

These constraints prevent duplicate values where uniqueness is required.

### NOT NULL and value validation

The ERD marks required attributes with `NOT NULL`. During PostgreSQL implementation, additional `CHECK` constraints will be considered for business rules such as:

- `unit_price > 0`
- `quantity > 0`
- `quantity_on_hand >= 0`
- `reorder_level >= 0`
- `amount >= 0`

`NOT NULL` prevents missing values but does not prevent negative prices or quantities. These rules must be enforced separately.

## 5. Normalisation

The ShopSmart relational schema separates customer, category, product, inventory, order, order-item, payment, and delivery information into eight tables. This separation reduces unnecessary duplication and supports data integrity.

### First Normal Form (1NF)

The design uses individual attributes rather than repeating groups. Products purchased in an order are represented as separate rows in `ORDER_ITEM`, with each row storing one product reference, its quantity, and its purchase price.

### Second Normal Form (2NF)

The tables use single-column primary keys. Therefore, partial dependencies on part of a composite primary key do not arise. The design still requires consideration of candidate keys and functional dependencies when formally verifying normalisation.

### Third Normal Form (3NF)

The design separates information according to its subject. For example, category names and descriptions are stored in `CATEGORY`, while product details are stored in `PRODUCT`. Customer details are stored in `CUSTOMER`, rather than repeated in each order. This reduces unnecessary duplication and update anomalies.

The schema structure is consistent with a 3NF design. A complete formal verification would document the functional dependencies and confirm that every non-key attribute depends on a candidate key, the whole key, and nothing but the key.

### Historical purchase prices

`ORDER_ITEM.unit_price_at_purchase` stores the price associated with an order line at the time of purchase. `PRODUCT.unit_price` stores the current product price. These attributes represent different business facts, so keeping both is intentional rather than unnecessary duplication.

## 6. Design Decisions and Limitations

The current design deliberately assumes:

- One inventory location for the store.
- One inventory record per product.
- One payment record per order.
- One delivery record per order.

The unique foreign keys support the “at most one” part of the payment, delivery, and inventory relationships. Guaranteeing the existence of these records for every parent requires additional implementation or application logic.

The model could be extended in future to support multiple warehouses, stock movement history, multiple payment attempts, refunds, or split deliveries. These features are outside the current scope.

## 7. Implementation and Verification

## 7. Implementation and Verification

The relational schema was implemented in PostgreSQL using the `shopsmart` database. All eight tables were created successfully: `customer`, `category`, `product`, `inventory`, `customer_order`, `order_item`, `payment`, and `delivery`.

The implementation includes primary keys, foreign keys, unique constraints, `NOT NULL` requirements, default values, and `CHECK` constraints to enforce data integrity.

### Sample Data

Sample records were inserted to demonstrate how the tables work together. The database contains records for customers, product categories, products, inventory, customer orders, order items, payments, and deliveries.

A SQL join across the customer, order, order-item, and product tables was executed successfully. The results demonstrated how customer orders can be linked to the products purchased and their quantities and purchase prices.

### Constraint Testing

The following invalid operations were tested in PostgreSQL:

- **Price constraint:** An attempt to insert a product with a price of zero was rejected by the `CHECK` constraint.
- **Foreign-key constraint:** An attempt to insert a product referencing a non-existent category was rejected by the foreign-key constraint.
- **Unique constraint:** An attempt to insert a customer using an email address already registered in the database was rejected by the unique constraint.

These tests demonstrate that PostgreSQL enforces the selected data-integrity rules and prevents the tested invalid records from being inserted.

### Evidence

Supporting SQL scripts and screenshots are organised in the following directories:

- `erd/` — ERD preview and editable draw.io export.
- `scripts/` — relational schema and sample-data SQL scripts.
- `tests/` — constraint-test SQL script and screenshots of rejected operations.
- `screenshots/` — table listings, table structure, sample data, and joined-query results.

The evidence documents the design and implementation of the ShopSmart database. The scripts and screenshots should be reviewed together to understand the schema, the test cases, and their observed results.