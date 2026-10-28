
-- ShopSmart synthetic data expansion
-- Stage 1A: Add categories without duplicating existing ones.

INSERT INTO category (category_name, description)
VALUES
    ('Computers', 'Computers and computer accessories'),
    ('Mobile Phones', 'Mobile phones and related accessories'),
    ('Fashion', 'Clothing and fashion accessories'),
    ('Health and Beauty', 'Personal care and beauty products'),
    ('Sports and Outdoors', 'Sports equipment and outdoor products'),
    ('Toys and Games', 'Toys, games, and recreational products'),
    ('Office Supplies', 'Stationery and office equipment')
ON CONFLICT (category_name) DO NOTHING
RETURNING category_id, category_name;


-- Stage 1B: Add products across the available categories.

INSERT INTO product (
    category_id, product_name, description, unit_price, active
)
SELECT
    c.category_id,
    v.product_name,
    v.description,
    v.unit_price,
    TRUE
FROM (
    VALUES
        ('Computers', 'Laptop Computer', 'Portable laptop computer', 450000.00),
        ('Computers', 'Desktop Computer', 'Desktop personal computer', 520000.00),
        ('Computers', 'USB Keyboard', 'Wired USB keyboard', 12000.00),
        ('Computers', 'Computer Monitor', '24 inch computer monitor', 145000.00),
        ('Computers', 'External Hard Drive', 'External data storage drive', 95000.00),
        ('Computers', 'USB Flash Drive', '64GB USB flash drive', 15000.00),
        ('Mobile Phones', 'Android Smartphone', 'Android mobile smartphone', 280000.00),
        ('Mobile Phones', 'Basic Mobile Phone', 'Basic mobile phone', 35000.00),
        ('Mobile Phones', 'Phone Charger', 'USB phone charging adapter', 8500.00),
        ('Mobile Phones', 'Phone Case', 'Protective smartphone case', 5000.00),
        ('Mobile Phones', 'Wireless Earbuds', 'Bluetooth wireless earbuds', 32000.00),
        ('Fashion', 'Cotton T-Shirt', 'Cotton casual T-shirt', 7500.00),
        ('Fashion', 'Denim Jeans', 'Casual denim jeans', 18000.00),
        ('Fashion', 'Running Shoes', 'Everyday running shoes', 35000.00),
        ('Fashion', 'Leather Belt', 'Casual leather belt', 9000.00),
        ('Fashion', 'Backpack', 'Everyday backpack', 22000.00),
        ('Health and Beauty', 'Electric Toothbrush', 'Rechargeable electric toothbrush', 28000.00),
        ('Health and Beauty', 'Hair Dryer', 'Handheld hair dryer', 24000.00),
        ('Health and Beauty', 'Skin Moisturiser', 'Daily skin moisturiser', 6500.00),
        ('Health and Beauty', 'Digital Thermometer', 'Digital temperature thermometer', 7000.00),
        ('Health and Beauty', 'First Aid Kit', 'Household first aid kit', 12000.00),
        ('Sports and Outdoors', 'Football', 'Standard size football', 18000.00),
        ('Sports and Outdoors', 'Yoga Mat', 'Exercise yoga mat', 14000.00),
        ('Sports and Outdoors', 'Dumbbell Set', 'Home exercise dumbbell set', 55000.00),
        ('Sports and Outdoors', 'Water Bottle', 'Reusable sports water bottle', 4500.00),
        ('Sports and Outdoors', 'Camping Tent', 'Two person camping tent', 85000.00),
        ('Toys and Games', 'Board Game', 'Family strategy board game', 16000.00),
        ('Toys and Games', 'Building Blocks', 'Creative building block set', 12500.00),
        ('Toys and Games', 'Remote Control Car', 'Remote controlled toy car', 27000.00),
        ('Toys and Games', 'Puzzle Set', 'Jigsaw puzzle set', 8000.00),
        ('Toys and Games', 'Playing Cards', 'Standard playing card deck', 2500.00),
        ('Office Supplies', 'Notebook Pack', 'Pack of ruled notebooks', 6000.00),
        ('Office Supplies', 'Ballpoint Pens', 'Pack of ballpoint pens', 2500.00),
        ('Office Supplies', 'Office Chair', 'Adjustable office chair', 95000.00),
        ('Office Supplies', 'Desk Lamp', 'LED desk lamp', 18000.00),
        ('Office Supplies', 'Printer Paper', 'Ream of printer paper', 6500.00),
        ('Electronics', 'Bluetooth Speaker', 'Portable Bluetooth speaker', 42000.00),
        ('Electronics', 'Power Bank', 'Portable USB power bank', 22000.00),
        ('Electronics', 'Surge Protector', 'Multi outlet surge protector', 15000.00),
        ('Electronics', 'Digital Camera', 'Compact digital camera', 210000.00),
        ('Home and Kitchen', 'Blender', 'Kitchen countertop blender', 38000.00),
        ('Home and Kitchen', 'Microwave Oven', 'Countertop microwave oven', 125000.00),
        ('Home and Kitchen', 'Rice Cooker', 'Electric rice cooker', 29000.00),
        ('Home and Kitchen', 'Cookware Set', 'Multi piece cookware set', 65000.00),
        ('Books', 'SQL Programming Guide', 'Introductory SQL programming book', 14500.00),
        ('Books', 'Database Design Handbook', 'Relational database design book', 17500.00),
        ('Books', 'Computer Networks Textbook', 'Computer networking textbook', 16000.00)
) AS v(category_name, product_name, description, unit_price)
JOIN category AS c
    ON c.category_name = v.category_name
WHERE NOT EXISTS (
    SELECT 1
    FROM product AS existing
    WHERE existing.product_name = v.product_name
)
RETURNING product_id, product_name, category_id;
