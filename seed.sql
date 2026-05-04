USE spartanexchange;

INSERT IGNORE INTO categories (category_id, category_name, category_description) VALUES
(1, 'Books', 'Textbooks and course materials'),
(2, 'Electronics', 'Calculators, laptops, and accessories'),
(3, 'Furniture', 'Dorm and apartment furniture'),
(4, 'Academic Supplies', 'School and lab supplies');

INSERT IGNORE INTO users (user_id, full_name, preferred_name, sjsu_email, password_hash, contact_details, status) VALUES
(1, 'Admin User', 'Admin', 'admin@sjsu.edu', 'admin123', 'admin@sjsu.edu', 'Active'),
(2, 'Student User', 'Student', 'student@sjsu.edu', 'password123', 'student@sjsu.edu', 'Active');

INSERT IGNORE INTO administrators (admin_id, user_id) VALUES
(1, 1);

INSERT IGNORE INTO products
(product_id, product_name, product_description, price, product_condition, quantity_available, product_status, low_stock_notice, category_id, created_by_admin_id)
VALUES
(1, 'Database Systems Textbook', 'Used textbook for database design and SQL practice.', 45.00, 'Good', 8, 'Available', 'no', 1, 1),
(2, 'Scientific Calculator', 'TI-style calculator for math and engineering classes.', 25.00, 'Like New', 4, 'Available', 'yes', 2, 1),
(3, 'Dorm Desk Chair', 'Comfortable chair for study setup.', 30.00, 'Used', 3, 'Available', 'yes', 3, 1),
(4, 'Lab Notebook Pack', 'Three unused lab notebooks.', 12.50, 'New', 15, 'Available', 'no', 4, 1);
