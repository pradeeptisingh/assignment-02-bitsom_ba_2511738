-- ============================================================
-- Part 1.2 — Schema Design: 3NF Normalisation of orders_flat.csv
-- ============================================================
-- Tables:
--   1. sales_reps      — SR attributes (eliminates rep data redundancy)
--   2. customers       — Customer master (eliminates customer data redundancy)
--   3. products        — Product catalogue (eliminates product data redundancy)
--   4. orders          — Order header (links customer + rep + date)
--   5. order_items     — Order lines (links order + product + qty)
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- TABLE 1: sales_reps

CREATE TABLE sales_reps (
    sales_rep_id   VARCHAR(10)  PRIMARY KEY,
    sales_rep_name VARCHAR(100) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    office_address VARCHAR(255) NOT NULL
);

INSERT INTO sales_reps (sales_rep_id, sales_rep_name, email, office_address) VALUES
    ('SR01', 'Deepak Joshi', 'deepak@corp.com', 'Mumbai HQ, Nariman Point, Mumbai - 400021'),
    ('SR02', 'Anita Desai',  'anita@corp.com',  'Delhi Office, Connaught Place, New Delhi - 110001'),
    ('SR03', 'Ravi Kumar',   'ravi@corp.com',   'South Zone, MG Road, Bangalore - 560001'),
    ('SR04', 'Meena Pillai', 'meena@corp.com',  'East Zone, Park Street, Kolkata - 700016'),
    ('SR05', 'Sanjay Nair',  'sanjay@corp.com', 'West Zone, FC Road, Pune - 411004');


-- ────────────────────────────────────────────────────────────
-- TABLE 2: customers

CREATE TABLE customers (
    customer_id   VARCHAR(10)  PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    city          VARCHAR(100) NOT NULL
);

INSERT INTO customers (customer_id, customer_name, email, city) VALUES
    ('C001', 'Rohan Mehta',  'rohan@gmail.com',  'Mumbai'),
    ('C002', 'Priya Sharma', 'priya@gmail.com',  'Delhi'),
    ('C003', 'Amit Verma',   'amit@gmail.com',   'Bangalore'),
    ('C004', 'Sneha Iyer',   'sneha@gmail.com',  'Chennai'),
    ('C005', 'Vikram Singh', 'vikram@gmail.com', 'Mumbai'),
    ('C006', 'Neha Gupta',   'neha@gmail.com',   'Delhi'),
    ('C007', 'Arjun Nair',   'arjun@gmail.com',  'Bangalore'),
    ('C008', 'Kavya Rao',    'kavya@gmail.com',  'Hyderabad');


-- ────────────────────────────────────────────────────────────
-- TABLE 3: products

CREATE TABLE products (
    product_id   VARCHAR(10)  PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category     VARCHAR(100) NOT NULL,
    unit_price   DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0)
);

INSERT INTO products (product_id, product_name, category, unit_price) VALUES
    ('P001', 'Laptop',        'Electronics', 55000.00),
    ('P002', 'Mouse',         'Electronics',   800.00),
    ('P003', 'Desk Chair',    'Furniture',    8500.00),
    ('P004', 'Notebook',      'Stationery',    120.00),
    ('P005', 'Headphones',    'Electronics',  3200.00),
    ('P006', 'Standing Desk', 'Furniture',   22000.00),
    ('P007', 'Pen Set',       'Stationery',    250.00),
    ('P008', 'Webcam',        'Electronics',  2100.00),
    ('P009', 'Keyboard',      'Electronics',  1500.00),   
    ('P010', 'Monitor',       'Electronics', 18000.00);   


-- ────────────────────────────────────────────────────────────
-- TABLE 4: orders

CREATE TABLE orders (
    order_id     VARCHAR(15) PRIMARY KEY,
    customer_id  VARCHAR(10) NOT NULL,
    sales_rep_id VARCHAR(10) NOT NULL,
    order_date   DATE        NOT NULL,
    CONSTRAINT fk_orders_customer  FOREIGN KEY (customer_id)  REFERENCES customers (customer_id),
    CONSTRAINT fk_orders_sales_rep FOREIGN KEY (sales_rep_id) REFERENCES sales_reps (sales_rep_id)
);

INSERT INTO orders (order_id, customer_id, sales_rep_id, order_date) VALUES
    ('ORD1001', 'C004', 'SR03', '2023-01-05'),
    ('ORD1002', 'C002', 'SR02', '2023-01-17'),
    ('ORD1013', 'C004', 'SR03', '2023-02-08'),
    ('ORD1018', 'C004', 'SR03', '2023-02-20'),
    ('ORD1022', 'C005', 'SR01', '2023-10-15'),
    ('ORD1027', 'C002', 'SR02', '2023-11-02'),
    ('ORD1033', 'C004', 'SR01', '2023-03-14'),
    ('ORD1036', 'C004', 'SR02', '2023-04-01'),
    ('ORD1037', 'C002', 'SR03', '2023-03-06'),
    ('ORD1042', 'C004', 'SR01', '2023-05-22'),
    ('ORD1043', 'C004', 'SR02', '2023-06-10'),
    ('ORD1046', 'C004', 'SR03', '2023-07-01'),
    ('ORD1051', 'C004', 'SR01', '2023-08-03'),
    ('ORD1053', 'C004', 'SR02', '2023-09-12'),
    ('ORD1054', 'C002', 'SR03', '2023-10-04'),
    ('ORD1061', 'C006', 'SR01', '2023-10-27'),
    ('ORD1067', 'C004', 'SR01', '2023-11-15'),
    ('ORD1075', 'C005', 'SR03', '2023-04-18'),
    ('ORD1076', 'C004', 'SR03', '2023-05-16'),
    ('ORD1083', 'C006', 'SR01', '2023-07-03'),
    ('ORD1084', 'C004', 'SR02', '2023-07-20'),
    ('ORD1091', 'C001', 'SR01', '2023-07-24'),
    ('ORD1098', 'C007', 'SR03', '2023-10-03'),
    ('ORD1110', 'C004', 'SR02', '2023-08-18'),
    ('ORD1114', 'C001', 'SR01', '2023-08-06'),
    ('ORD1118', 'C006', 'SR02', '2023-11-10'),
    ('ORD1125', 'C004', 'SR01', '2023-09-05'),
    ('ORD1130', 'C004', 'SR03', '2023-09-22'),
    ('ORD1131', 'C008', 'SR02', '2023-06-22'),
    ('ORD1132', 'C003', 'SR02', '2023-03-07'),
    ('ORD1133', 'C001', 'SR03', '2023-10-16'),
    ('ORD1136', 'C004', 'SR01', '2023-10-30'),
    ('ORD1137', 'C005', 'SR02', '2023-05-10'),
    ('ORD1142', 'C004', 'SR03', '2023-11-05'),
    ('ORD1146', 'C004', 'SR01', '2023-11-20'),
    ('ORD1153', 'C006', 'SR01', '2023-02-14'),
    ('ORD1161', 'C004', 'SR02', '2023-09-29'),
    ('ORD1162', 'C006', 'SR03', '2023-09-29'),
    ('ORD1179', 'C004', 'SR01', '2023-12-01'),
    ('ORD1183', 'C004', 'SR01', '2023-12-10'),
    ('ORD1185', 'C003', 'SR03', '2023-06-15');


-- ────────────────────────────────────────────────────────────
-- TABLE 5: order_items

CREATE TABLE order_items (
    item_id    INT            PRIMARY KEY AUTO_INCREMENT,   
    order_id   VARCHAR(15)    NOT NULL,
    product_id VARCHAR(10)    NOT NULL,
    quantity   INT            NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),  
    CONSTRAINT fk_items_order   FOREIGN KEY (order_id)   REFERENCES orders   (order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products (product_id),
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id)  
);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    ('ORD1001', 'P002', 1,   800.00),
    ('ORD1002', 'P005', 1,  3200.00),
    ('ORD1013', 'P007', 3,   250.00),
    ('ORD1018', 'P006', 2, 22000.00),
    ('ORD1022', 'P002', 5,   800.00),
    ('ORD1027', 'P004', 4,   120.00),
    ('ORD1033', 'P002', 2,   800.00),
    ('ORD1036', 'P005', 3,  3200.00),
    ('ORD1037', 'P007', 2,   250.00),
    ('ORD1042', 'P001', 1, 55000.00),
    ('ORD1043', 'P005', 2,  3200.00),
    ('ORD1046', 'P005', 1,  3200.00),
    ('ORD1051', 'P002', 4,   800.00),
    ('ORD1053', 'P007', 2,   250.00),
    ('ORD1054', 'P001', 1, 55000.00),
    ('ORD1061', 'P001', 4, 55000.00),
    ('ORD1067', 'P003', 1,  8500.00),
    ('ORD1075', 'P003', 3,  8500.00),
    ('ORD1076', 'P006', 5, 22000.00),
    ('ORD1083', 'P007', 2,   250.00),
    ('ORD1084', 'P006', 2, 22000.00),
    ('ORD1091', 'P006', 3, 22000.00),
    ('ORD1098', 'P001', 2, 55000.00),
    ('ORD1110', 'P007', 4,   250.00),
    ('ORD1114', 'P007', 2,   250.00),
    ('ORD1118', 'P007', 5,   250.00),
    ('ORD1125', 'P001', 2, 55000.00),
    ('ORD1130', 'P004', 3,   120.00),
    ('ORD1131', 'P001', 4, 55000.00),
    ('ORD1132', 'P007', 5,   250.00),
    ('ORD1133', 'P004', 1,   120.00),
    ('ORD1136', 'P004', 2,   120.00),
    ('ORD1137', 'P007', 1,   250.00),
    ('ORD1142', 'P004', 3,   120.00),
    ('ORD1146', 'P001', 1, 55000.00),
    ('ORD1153', 'P007', 3,   250.00),
    ('ORD1161', 'P004', 2,   120.00),
    ('ORD1162', 'P004', 3,   120.00),
    ('ORD1179', 'P007', 3,   250.00),
    ('ORD1183', 'P003', 2,  8500.00),
    ('ORD1185', 'P008', 1,  2100.00);
