
/*
MIT 8103 - Advanced Database Systems
Portfolio 4: NoSQL and Advanced Data Models

Case Study: ShopSmart E-commerce and Inventory Management System
Database: shopsmart_nosql
Platform: MongoDB Atlas
Model: Document-oriented database

Note:
These commands are written for mongosh.
They are provided as implementation documentation and can
be executed in mongosh when connected to the Atlas cluster.
*/

// 1. Select the ShopSmart NoSQL database
use("shopsmart_nosql");

// 2. View available collections
db.getCollectionNames();

// 3. INSERT: Add a product document
db.products.insertOne({
  product_id: 1,
  product_name: "Wireless Mouse",
  category: "Electronics",
  unit_price: 8500,
  quantity_in_stock: 50,
  active: true
});

// 4. INSERT: Add an order with embedded customer,
// order items and payment information
db.orders.insertOne({
  order_id: 1,
  customer: {
    customer_id: 1,
    customer_name: "Amara Okafor",
    email: "amara.okafor@example.com"
  },
  order_date: "2026-11-12",
  order_status: "Processing",
  items: [
    {
      product_id: 1,
      product_name: "Wireless Mouse",
      quantity: 2,
      unit_price: 8500
    },
    {
      product_id: 2,
      product_name: "Electric Kettle",
      quantity: 1,
      unit_price: 18500
    }
  ],
  payment: {
    payment_method: "Card",
    payment_status: "Paid"
  },
  total_amount: 35500
});

// 5. READ: Retrieve all products
db.products.find();

// 6. READ: Find products by category
db.products.find({
  category: "Electronics"
});

// 7. READ: Find products costing more than 10000
db.products.find({
  unit_price: { $gt: 10000 }
});

// 8. UPDATE: Change Wireless Mouse stock quantity
// The demonstrated Atlas update changed stock from 50 to 45.
db.products.updateOne(
  { product_id: 1 },
  { $set: { quantity_in_stock: 45 } }
);

// Verify the updated product
db.products.findOne({
  product_id: 1
});

// 9. DELETE: Insert a temporary test document
// This is a demonstration record, not a ShopSmart product.
db.products.insertOne({
  product_id: 999,
  product_name: "Temporary Test Product",
  category: "Testing",
  unit_price: 100,
  quantity_in_stock: 1,
  active: false
});

// 10. DELETE: Remove the temporary test document
db.products.deleteOne({
  product_id: 999
});

// Verify deletion: expected result is null
db.products.findOne({
  product_id: 999
});

// 11. READ: Retrieve an order and its embedded items
db.orders.findOne({
  order_id: 1
});
