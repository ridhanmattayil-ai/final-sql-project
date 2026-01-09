select * from category;
select * from customers;
select * from inventory;
select * from order_items;
select * from orders;
select * from payments;
select * from products;
select * from sellers;
select * from shippings;


--Total Revenue

select
round(sum(oi.quantity * oi.price_per_unit):: numeric, 2) 
as total_revenue
from order_items oi;



--Monthly Sales Trend

select
DATE_TRUNC('month', o.order_date):: date as month,
ROUND(sum(oi.quantity * oi.price_per_unit):: numeric , 2) as revenue
from orders o
join order_items oi on o.order_id = oi.order_id
group by month
order by month 
limit 7;



--Revenue by Category

select
c.category_name,
round(sum(oi.quantity * oi.price_per_unit):: numeric, 2) 
as category_revenue
from order_items oi
join products p on oi.product_id = p.product_id
join category c on p.category_id = c.category_id
group by c.category_name
order by category_revenue desc;


--Top 10 Best-Selling Products

select
p.product_name,
sum(oi.quantity) as total_quantity_sold,
round(sum(oi.quantity * oi.price_per_unit):: numeric, 2)
as total_sales
from order_items oi
join products p on oi.product_id = p.product_id
group by p.product_name
order by total_sales desc
limit  10;




--Delivered vs Returned Orders

select 
delivery_status,
count(*) as total_orders
from shippings
group by delivery_status;



--Orders Returned by Category

SELECT 
c.category_name,
COUNT(*) AS returned_orders
FROM shippings sh
JOIN orders o ON sh.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE sh.return_date IS NOT NULL
GROUP BY c.category_name;


--Products with Highest Returns


SELECT 
p.product_name,
COUNT(*) AS return_count
FROM shippings sh
JOIN orders o ON sh.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE sh.return_date IS NOT NULL
GROUP BY p.product_name
ORDER BY return_count DESC
limit 7;


--Rank Products by Revenue (Window Function)


select
p.product_name,
round(sum(oi.quantity * oi.price_per_unit):: numeric ,2) 
as revenue,
rank() over (order by sum(oi.quantity * oi.price_per_unit) desc) 
as revenue_rank
from order_items oi
join products p on oi.product_id = p.product_id
group by p.product_name
limit 7;


--Best Product in Each Category

select *from (select
c.category_name,
p.product_name,
round(sum(oi.quantity * oi.price_per_unit):: numeric , 2)
as revenue,
rank() over (partition by c.category_name 
order by sum(oi.quantity * oi.price_per_unit) desc) as rank
from order_items oi
join products p on oi.product_id = p.product_id
join category c on p.category_id = c.category_id
group by c.category_name, p.product_name
) t
where rank = 1;


--Revenue by Seller

SELECT 
s.seller_name,
ROUND(SUM(oi.quantity * oi.price_per_unit):: numeric , 2)
AS seller_revenue
FROM sellers s
JOIN orders o ON s.seller_id = o.seller_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY s.seller_name
ORDER BY seller_revenue DESC
limit 7;

--Seller Order Count

SELECT 
s.seller_name,
COUNT(o.order_id) AS total_orders
FROM sellers s
JOIN orders o ON s.seller_id = o.seller_id
GROUP BY s.seller_name
ORDER BY total_orders DESC
limit 7;



--Which state has the most customers?

select 
state,
count(*) as total_customers
from customers
group by state
order by total_customers desc
limit 5
;
 

--What is the average order value?


select
round(
(sum(oi.quantity * oi.price_per_unit)::numeric 
/ nullif(count(distinct o.order_id), 0)),2
) as avg_order_value
from orders o
join order_items oi on o.order_id = oi.order_id;




--Customers with Most  Orders
SELECT 
c.customer_id,
c.first_name,
COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name
HAVING COUNT(o.order_id) > 3 order by total_orders desc
limit 5;





