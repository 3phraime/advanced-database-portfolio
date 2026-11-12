# Portfolio 4: NoSQL and Advanced Data Models
 
**NoSQL Model:** Document-oriented database

## 1. Introduction

This portfolio explores the implementation of a NoSQL database using the ShopSmart E-commerce and Inventory Management System developed in the previous portfolios.

The purpose is to demonstrate how a document-oriented database can store and manage e-commerce information using flexible, JSON-like documents.

MongoDB Atlas was selected as the cloud-hosted database platform. It was used to create the ShopSmart NoSQL database, insert product and order documents, and perform basic data operations.

## 2. Selected NoSQL Data Model

The selected model is the **document-oriented data model**.

Unlike relational databases, which organise information into tables containing rows and columns, MongoDB stores information as documents in collections. Documents use BSON, a binary representation of JSON-like data.

This model allows related information to be embedded within a single document.

For ShopSmart, customer details, order items and payment information can be stored within an order document.

## 3. Database Implementation

The implementation was carried out using MongoDB Atlas without installing a local database server.

**Environment details:**

- Platform: MongoDB Atlas
- Cluster: `miva-cluster`
- Database: `shopsmart_nosql`
- Collections: `products` and `orders`
- Deployment: Free-tier cloud cluster
- MongoDB version displayed in Atlas: 8.0.37

### 3.1 Products Collection

The `products` collection stores ShopSmart product information.

Three product documents were inserted:

| Product ID | Product name | Category | Unit price | Stock |
|---|---|---|---:|---:|
| 1 | Wireless Mouse | Electronics | 8,500 | 45 |
| 2 | Electric Kettle | Home and Kitchen | 18,500 | 30 |
| 3 | Database Systems Textbook | Books | 12,000 | 25 |

The Wireless Mouse stock quantity was updated from 50 to 45 during the update operation.

Each product document contains its product identifier, name, category, price, stock quantity and active status. MongoDB also automatically generates a unique `_id` field for each document.

### 3.2 Orders Collection and Embedded Documents

The `orders` collection demonstrates how related information can be embedded in one document.

The implemented example contains:

- Customer information as an embedded object.
- Order items as an array of embedded objects.
- Payment details as an embedded object.
- Order date and status.
- Total order amount.

The example order contains two items:

| Product | Quantity | Unit price | Line total |
|---|---:|---:|---:|
| Wireless Mouse | 2 | 8,500 | 17,000 |
| Electric Kettle | 1 | 18,500 | 18,500 |
| **Total** | | | **35,500** |

This structure demonstrates how MongoDB can store related order information together rather than requiring separate relational tables for the order and its order items.

## 4. CRUD Operations

CRUD refers to Create, Read, Update and Delete operations. These operations were demonstrated using MongoDB Atlas Data Explorer.

### 4.1 Create

Product and order documents were inserted into their respective collections.

### 4.2 Read

A category query was used to retrieve products belonging to Electronics:

```javascript
db.products.find({ category: "Electronics" });
```

The query returned the Wireless Mouse document.

### 4.3 Update

The stock quantity of the Wireless Mouse was changed from 50 to 45.

```javascript
db.products.updateOne(
  { product_id: 1 },
  { $set: { quantity_in_stock: 45 } }
);
```

The updated document was retrieved to verify the change.

### 4.4 Delete

A temporary test product with `product_id: 999` was inserted and subsequently deleted.

```javascript
db.products.deleteOne({ product_id: 999 });
```

A subsequent search for the same product returned no results, confirming that the deletion was successful.

## 5. Comparison Between PostgreSQL and MongoDB

The ShopSmart system was initially designed and implemented using PostgreSQL as a relational database. MongoDB was subsequently used to demonstrate a document-oriented approach to managing similar business information.

| Feature | PostgreSQL | MongoDB |
|---|---|---|
| Data model | Relational | Document-oriented |
| Storage structure | Tables, rows and columns | Collections and documents |
| Relationships | Foreign keys and joins | Embedded documents and references |
| Schema | Structured relational schema | Flexible document structure |
| Order items | Stored in a separate table | Can be embedded in an order document |
| Data integrity | Relational constraints | Document validation and application logic |

In PostgreSQL, customer orders and order items are stored in separate related tables. In MongoDB, related order information can be embedded within a single document.

Both approaches can support the ShopSmart business requirements, but they organise and retrieve data differently.

## 6. Suitability of MongoDB for ShopSmart

MongoDB is suitable for demonstrating the ShopSmart e-commerce system for several reasons.

**Flexible data structure:** Products may have different attributes depending on their categories. A document model allows product records to contain different fields where necessary.

**Embedded order information:** Customer details, order items and payment information can be grouped into one order document. This can simplify retrieval when the application frequently needs the complete order.

**Scalability:** MongoDB Atlas provides a managed cloud database platform that can support database growth and distributed deployment options.

**Development flexibility:** Its JSON-like document structure is convenient for applications that exchange data in JSON format.

### 6.1 Limitations

MongoDB also has limitations that should be considered.

- Embedding large or frequently changing information can result in document growth and duplication.
- Maintaining consistency across duplicated information requires careful application design.
- Complex relationships and reporting may be more straightforward in a relational database.
- A flexible schema does not eliminate the need for data validation and business rules.

For these reasons, PostgreSQL remains appropriate for ShopSmart operations that depend heavily on relational integrity, while MongoDB provides an alternative for flexible, document-based data management.

## 7. Conclusion

This portfolio demonstrated the use of MongoDB Atlas as a document-oriented NoSQL database for the ShopSmart case study.

The implementation included creating the database and collections, inserting product and order documents, embedding related information within an order document, and performing Create, Read, Update and Delete operations.

The comparison with PostgreSQL showed that relational and document databases provide different approaches to data organisation. The choice depends on the application's data structure, consistency requirements and access patterns.

## 8. Project Files and Evidence

The supporting implementation files are organised as follows:

```text
portfolio-4-nosql/
├── README.md
├── screenshots/
│   ├── 01_mongodb_atlas_cluster.png
│   ├── 02_database_collections.png
│   ├── 03_product_documents.png
│   ├── 04_order_document_embedded_items.png
│   ├── 05_product_read_query.png
│   ├── 06_product_update.png
│   ├── 07_before_product_delete.png
│   └── 08_after_product_delete.png
└── scripts/
    └── shopsmart_nosql_queries.js
```

The screenshots provide evidence of the Atlas environment, database structure, inserted documents and CRUD operations. The JavaScript file records the MongoDB commands used in the practical exercise.

## 9. Reflection

This exercise provided practical experience with a document-oriented NoSQL database and demonstrated how MongoDB stores related information in flexible documents.

It also improved my understanding of the differences between relational and NoSQL databases, particularly how data modelling choices affect relationships, data consistency and information retrieval.

Using MongoDB Atlas provided an opportunity to work with a cloud-hosted database without requiring a local database server installation.