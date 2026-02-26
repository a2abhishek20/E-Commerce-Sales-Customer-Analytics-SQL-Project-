create database project;
use project;

CREATE DATABASE ecommerce_project;
USE ecommerce_project;

-- Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(10),
    city VARCHAR(50),
    state VARCHAR(50),
    signup_date DATE
);

INSERT INTO customers VALUES
(1,'Amit Sharma','Male','Delhi','Delhi','2023-01-15'),
(2,'Priya Verma','Female','Mumbai','Maharashtra','2023-02-20'),
(3,'Rahul Singh','Male','Bangalore','Karnataka','2023-03-05'),
(4,'Sneha Kapoor','Female','Delhi','Delhi','2023-04-10'),
(5,'Arjun Mehta','Male','Pune','Maharashtra','2023-05-25'),
(6,'Kriti Jain','Female','Jaipur','Rajasthan','2023-06-15'),
(7,'Rohit Yadav','Male','Lucknow','UP','2023-07-01'),
(8,'Neha Joshi','Female','Ahmedabad','Gujarat','2023-08-12'),
(9,'Vikas Rao','Male','Chennai','Tamil Nadu','2023-09-20'),
(10,'Ananya Das','Female','Kolkata','West Bengal','2023-10-05');

-- Products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

INSERT INTO products VALUES
(101,'Laptop','Electronics',60000),
(102,'Phone','Electronics',30000),
(103,'Headphones','Electronics',2000),
(104,'Shirt','Clothing',1500),
(105,'Shoes','Clothing',2500),
(106,'Watch','Accessories',5000),
(107,'Bag','Accessories',2000),
(108,'Tablet','Electronics',40000),
(109,'Camera','Electronics',45000),
(110,'Jacket','Clothing',3000);

-- Orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO orders VALUES
(1001,1,'2024-01-10','Delivered'),
(1002,2,'2024-01-12','Delivered'),
(1003,3,'2024-01-15','Cancelled'),
(1004,4,'2024-02-01','Delivered'),
(1005,5,'2024-02-05','Delivered'),
(1006,6,'2024-02-20','Returned'),
(1007,7,'2024-03-01','Delivered'),
(1008,8,'2024-03-10','Delivered'),
(1009,9,'2024-03-18','Delivered'),
(1010,10,'2024-04-01','Delivered');

-- Order Items
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO order_items VALUES
(1,1001,101,1),
(2,1001,103,2),
(3,1002,102,1),
(4,1003,104,3),
(5,1004,105,2),
(6,1005,106,1),
(7,1006,107,2),
(8,1007,108,1),
(9,1008,109,1),
(10,1009,110,2);

-- Payments
CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_mode VARCHAR(50),
    payment_status VARCHAR(20),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

INSERT INTO payments VALUES
(1,1001,'UPI','Completed'),
(2,1002,'Credit Card','Completed'),
(3,1003,'UPI','Failed'),
(4,1004,'Debit Card','Completed'),
(5,1005,'Cash on Delivery','Completed'),
(6,1006,'UPI','Refunded'),
(7,1007,'Credit Card','Completed'),
(8,1008,'UPI','Completed'),
(9,1009,'Debit Card','Completed'),
(10,1010,'UPI','Completed');

-- Returns
CREATE TABLE returns (
    return_id INT PRIMARY KEY,
    order_id INT,
    return_reason VARCHAR(100),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

INSERT INTO returns VALUES
(1,1006,'Damaged Product');

#Queries----------------------------------------------------------------------------------------------------------------------------------------------

#Show all customers from Delhi
select * from customers
where city="delhi";

#Count total customers
select count(*) as total_customers
from customers;

#Total number of orders
select count(*) as total_order
from orders;

#Show all delivered orders
select * from orders
where status="delivered";

#Find total number of products
select count(*) as total_product
from products;

#List unique categories
select distinct category 
from products;

#Show total quantity sold
select sum(quantity) as total_sold
from order_items;

#Count orders by payment mode
select payment_mode,count(*) as orders
from payments
group by payment_mode;

#Total revenue generated
select sum(price*quantity) as total_revenue
from products p
join order_items od on p.product_id=od.product_id;

#Revenue by category
select category, sum(price*quantity) as total_revenue
from products p
join order_items od on p.product_id=od.product_id
group by category;

#Top 3 highest priced products
SELECT product_name, price
FROM products
ORDER BY price DESC
LIMIT 3;

#Total orders per customer
select customer_id, count(order_id) as total_order
from orders
group by customer_id;

#Average order value
SELECT AVG(order_total) AS avg_order_value
FROM (
    SELECT order_id,
           SUM(oi.quantity * p.price) AS order_total
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY order_id
) t;

#Monthly sales revenue
select date_format(o.order_date, "%Y-%m") as month ,sum(p.price*ot.quantity) as revenue
from orders o
join order_items ot on o.order_id=ot.order_id
join products p on ot.product_id=p.product_id
group by month;

#Revenue by state
select c.state, sum(p.price*ot.quantity) as total_revenue
from customers c
join orders o on c.customer_id=o.customer_id
join order_items ot on o.order_id=ot.order_id
join products p on ot.product_id=p.product_id
group by c.state;

#Customers who made more than 1 order
SELECT customer_id,
       COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1;

#Most used payment method
select payment_mode,count(*) as most_used
from payments
group by payment_mode;

#Top 3 customers by revenue
select customer_name,sum(price*quantity) as total_revenue
from customers c
join orders o on c.customer_id=o.customer_id
join order_items od on o.order_id=od.order_id
join products p on od.product_id=p.product_id
group by customer_name
order by total_revenue desc
limit 3;

#Customer Lifetime Value (CLV)
SELECT c.customer_name,
       SUM(oi.quantity * p.price) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_name;

#Running total of revenue by date
select order_date ,
 SUM(od.quantity * p.price) AS daily_revenue,
sum(sum(price*quantity)) over (order by order_date) as running_sum
from orders o
join order_items od on o.order_id=od.order_id
join products p on od.product_id=p.product_id
group by order_date;

#Rank products by total sales
select product_name, sum(price*quantity),
rank()over(order by sum(price*quantity) desc) as product_rank
from products p
join order_items od on p.product_id=od.product_id
group by product_name;

#Find return rate (%)
select (count(r.return_id)*100/count(distinct o.order_id)) as return_rate_percentage
from orders o
left join returns r on o.order_id=r.order_id;

#Revenue contribution % by category
select category,revenue,(revenue*100/sum(revenue) over()) as revenue_percentage
from(
select category, sum(price*quantity) as revenue
from products p
join order_items od on p.product_id=od.product_id
group by category)t ;

#Cohort analysis (signup month vs revenue)
select date_format(c.signup_date, "%Y-%m") as cohort_month,sum(p.price*oi.quantity) as revenue
from customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY cohort_month;

#Find customers who never returned products
SELECT DISTINCT c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN returns r ON o.order_id = r.order_id
WHERE r.order_id IS NULL;