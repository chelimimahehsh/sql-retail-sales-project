-- 1. Create DB and use
CREATE DATABASE RetailSalesDB;
USE RetailSalesDB;
-- 2. Tables
CREATE TABLE IF NOT EXISTS Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    join_date DATE
);

CREATE TABLE IF NOT EXISTS Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE IF NOT EXISTS Order_Items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 3. Insert sample customers (12 rows)
INSERT INTO Customers VALUES
(1,'Mahesh','Bangalore','2023-01-01'),
(2,'Rahul','Hyderabad','2023-03-10'),
(3,'Sneha','Chennai','2023-05-22'),
(4,'Kiran','Pune','2023-02-14'),
(5,'Rohit','Mumbai','2023-04-18'),
(6,'Divya','Delhi','2023-06-21'),
(7,'Anjali','Kolkata','2023-07-12'),
(8,'Vijay','Bangalore','2023-03-05'),
(9,'Meera','Hyderabad','2023-08-15'),
(10,'Suresh','Chennai','2023-09-01'),
(11,'Tarun','Delhi','2023-02-02'),
(12,'Lakshmi','Pune','2023-04-25');

-- 4. Insert sample products (12 rows)
INSERT INTO Products VALUES
(101,'Laptop','Electronics',55000),
(102,'Mouse','Electronics',700),
(103,'Keyboard','Electronics',1200),
(104,'Monitor','Electronics',7500),
(105,'Headphones','Electronics',2500),
(106,'T-Shirt','Clothing',850),
(107,'Jeans','Clothing',1500),
(108,'Shoes','Footwear',2000),
(109,'Sandals','Footwear',1200),
(110,'Watch','Accessories',3000),
(111,'Bag','Accessories',1800),
(112,'Cap','Accessories',400);

-- 5. Insert orders (16 rows)
INSERT INTO Orders VALUES
(1001,1,'2023-06-01'),
(1002,2,'2023-06-02'),
(1003,1,'2023-06-05'),
(1004,3,'2023-06-07'),
(1005,4,'2023-06-09'),
(1006,5,'2023-06-12'),
(1007,6,'2023-06-14'),
(1008,7,'2023-06-15'),
(1009,8,'2023-06-17'),
(1010,9,'2023-06-18'),
(1011,10,'2023-06-20'),
(1012,11,'2023-06-22'),
(1013,12,'2023-06-25'),
(1014,3,'2023-06-26'),
(1015,5,'2023-06-28'),
(1016,8,'2023-06-30');

-- 6. Insert order items (32 rows)
INSERT INTO Order_Items VALUES
(1,1001,101,1),
(2,1001,102,2),
(3,1002,106,3),
(4,1002,110,1),
(5,1003,103,1),
(6,1003,105,1),
(7,1004,108,2),
(8,1004,112,1),
(9,1005,101,1),
(10,1005,111,1),
(11,1006,104,1),
(12,1006,107,2),
(13,1007,105,1),
(14,1007,109,2),
(15,1008,106,2),
(16,1008,107,1),
(17,1009,110,1),
(18,1009,108,1),
(19,1010,103,2),
(20,1010,112,3),
(21,1011,101,1),
(22,1011,108,2),
(23,1012,109,2),
(24,1012,111,1),
(25,1013,104,2),
(26,1013,106,3),
(27,1014,112,2),
(28,1014,110,1),
(29,1015,105,2),
(30,1015,103,1),
(31,1016,107,2),
(32,1016,102,3);

-- 7. Create helpful view
CREATE OR REPLACE VIEW v_customer_revenue AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.location,
    SUM(oi.quantity * p.price) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Items oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name, c.location;

-- Total Sales Revenue
SELECT SUM(oi.quantity * p.price) AS total_revenue
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id;

-- Top selling products
SELECT p.product_name, SUM(oi.quantity) AS total_units_sold
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units_sold DESC;

--Top revenue products
SELECT p.product_name, SUM(oi.quantity * p.price) AS revenue
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;

-- Customer spend (use view)

SELECT * FROM v_customer_revenue
ORDER BY total_spent DESC;

-- Category revenue
SELECT p.category, SUM(oi.quantity * p.price) AS revenue
FROM Products p
JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Daily sales
SELECT o.order_date, SUM(oi.quantity * p.price) AS total_sales
FROM Orders o
JOIN Order_Items oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- Customer rank by spending
SELECT customer_name, total_spent,
       RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
FROM v_customer_revenue;

SHOW VARIABLES LIKE 'secure_file_priv';

-- Example for Windows where secure_file_priv = C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
SELECT *
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\customer_revenue.csv'
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM v_customer_revenue;

