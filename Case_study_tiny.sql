CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(100)
);

INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
(1, 'John', 'Doe', 'johndoe@email.com'),
(2, 'Jane', 'Smith', 'janesmith@email.com'),
(3, 'Bob', 'Johnson', 'bobjohnson@email.com'),
(4, 'Alice', 'Brown', 'alicebrown@email.com'),
(5, 'Charlie', 'Davis', 'charliedavis@email.com'),
(6, 'Eva', 'Fisher', 'evafisher@email.com'),
(7, 'George', 'Harris', 'georgeharris@email.com'),
(8, 'Ivy', 'Jones', 'ivyjones@email.com'),
(9, 'Kevin', 'Miller', 'kevinmiller@email.com'),
(10, 'Lily', 'Nelson', 'lilynelson@email.com'),
(11, 'Oliver', 'Patterson', 'oliverpatterson@email.com'),
(12, 'Quinn', 'Roberts', 'quinnroberts@email.com'),
(13, 'Sophia', 'Thomas', 'sophiathomas@email.com');

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    product_name varchar(100),
    price decimal
);

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Product A', 10.00),
(2, 'Product B', 15.00),
(3, 'Product C', 20.00),
(4, 'Product D', 25.00),
(5, 'Product E', 30.00),
(6, 'Product F', 35.00),
(7, 'Product G', 40.00),
(8, 'Product H', 45.00),
(9, 'Product I', 50.00),
(10, 'Product J', 55.00),
(11, 'Product K', 60.00),
(12, 'Product L', 65.00),
(13, 'Product M', 70.00);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer,
    order_date date
);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1, 1, '2023-05-01'),
(2, 2, '2023-05-02'),
(3, 3, '2023-05-03'),
(4, 1, '2023-05-04'),
(5, 2, '2023-05-05'),
(6, 3, '2023-05-06'),
(7, 4, '2023-05-07'),
(8, 5, '2023-05-08'),
(9, 6, '2023-05-09'),
(10, 7, '2023-05-10'),
(11, 8, '2023-05-11'),
(12, 9, '2023-05-12'),
(13, 10, '2023-05-13'),
(14, 11, '2023-05-14'),
(15, 12, '2023-05-15'),
(16, 13, '2023-05-16');

CREATE TABLE order_items (
    order_id integer,
    product_id integer,
    quantity integer
);

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 2, 1),
(2, 3, 3),
(3, 1, 1),
(3, 3, 2),
(4, 2, 4),
(4, 3, 1),
(5, 1, 1),
(5, 3, 2),
(6, 2, 3),
(6, 1, 1),
(7, 4, 1),
(7, 5, 2),
(8, 6, 3),
(8, 7, 1),
(9, 8, 2),
(9, 9, 1),
(10, 10, 3),
(10, 11, 2),
(11, 12, 1),
(11, 13, 3),
(12, 4, 2),
(12, 5, 1),
(13, 6, 3),
(13, 7, 2),
(14, 8, 1),
(14, 9, 2),
(15, 10, 3),
(15, 11, 1),
(16, 12, 2),
(16, 13, 3);


-- 1) Which product has the highest price? Only return a single row.
Select product_name from products
order by price desc
limit 1;

-- 2) Which customer has made the most orders?
Select concat(first_name,' ',last_name) as Customer_Name,
count(o.order_id) as 'No_of_Orders' from customers c inner join orders o 
on o.customer_id=c.customer_id
group by 1
having count(o.order_id)>1;

-- 3) What’s the total revenue per product?
Select p.product_id,sum(quantity) as prod_qut,price,
sum(p.price*o.quantity) as Total_Revenue 
from order_items o inner join products p 
on p.product_id = o.product_id
group by p.product_id;

-- 4)Find the day with the highest revenue.
Select o.order_date ,sum(p.price*oi.quantity) as 'Total revenue' 
from products p inner join order_items oi
ON oi.product_id=p.product_id
inner join orders o
ON o.order_id= oi.order_id
group by o.order_date
order by o.order_date desc
limit 1;

-- 5.Find the first order (by date) for each customer.
with cte as
(select c.customer_id,concat(first_name,' ',last_name) as Full_Name,o.order_Date,
dense_rank() over(partition by c.customer_id order by o.order_date asc) as rnk
from customers c inner join orders o 
on o.customer_id=c.customer_id)

select customer_id,full_name,order_date from cte where rnk =1;

-- 6) Find the top 3 customers who have ordered the most distinct products
Select c.customer_id,concat(first_name,' ',last_name) as full_name ,
count(distinct oi.product_id) as distinct_product 
from customers c inner join orders o
ON o.customer_id = c.customer_id
inner join order_items oi 
on oi.order_id=o.order_id
group by 1,2
order by 3 desc 
limit 1;

-- 7.Which product has been bought the least in terms of quantity?
select sum(quantity) as produt_count
from order_items
group by product_id
order by 1
limit 1;

-- 8. For each order, determine if it was ‘Expensive’ (total over 300), 
-- ‘Affordable’ (total over 100), or ‘Cheap’.
WITH cte as(
select oi.order_id,sum(oi.quantity*p.price)as total_order
from order_items oi inner join products p 
ON P.product_id=oi.product_id
group by oi.order_id)

select order_id, total_order,(case 	
									when total_order>300 then 'Expensive'
                                    when total_order>100 then 'Affordable'
                                    else 'cheap'
                                    end)
as price_tag from cte
group by order_id ;
							
-- Find customers who have ordered the product with the highest price.
WITH cte AS (
    SELECT c.customer_id, CONCAT(first_name, ' ', last_name) AS full_name,p.price,
        DENSE_RANK() OVER (PARTITION BY c.customer_id ORDER BY p.price DESC) AS rnk
		FROM customers c
		INNER JOIN orders o ON c.customer_id = o.customer_id
		JOIN order_items oi ON oi.order_id = o.order_id
		JOIN products p ON p.product_id = oi.product_id
)
SELECT full_name
FROM cte
WHERE rnk = 1;