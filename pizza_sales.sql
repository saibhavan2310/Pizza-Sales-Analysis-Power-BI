-- Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(quantity * price), 2) AS total_revenue
FROM
    orders_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id;
    
-- Identify the highest-priced pizza.

select pt.name,p.price from pizza_types pt
join pizzas p on pt.pizza_type_id = p.pizza_type_id
order by p.price desc
limit 1;

-- Identify the most common pizza size ordered.

SELECT size,count(size) AS Pizza_Size FROM orders_details o
JOIN pizzas p ON o.pizza_id = p.pizza_id
group by size
order by count(size) desc;

-- List the top 5 most ordered pizza types along with their quantities.
select pt.name as Pizza_Name,sum(od.quantity) as Total_orders from pizza_types pt
join pizzas p on pt.pizza_type_id = p.pizza_type_id
join orders_details od on p.pizza_id = od.pizza_id
group by pt.name
order by Total_orders desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, sum(orders_details.quantity) as quantity from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by quantity desc;


-- Determine the distribution of orders by hour of the day.
select hour(order_time) as hour_time,count(hour(order_time)) as Count_orders from orders
group by hour(order_time)
order by Count_orders desc;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(category) from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Quantity), 2) AS Average_orders_per_day
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS Quantity
    FROM
        ORDERS
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue.
select pt.name,round(sum(price*quantity),2) as Revenue_Generated from pizza_types pt
join pizzas p on pt.pizza_type_id = p.pizza_type_id
join orders_details od on p.pizza_id = od.pizza_id
group by pt.name
order by Revenue_Generated desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pt.category,round(sum(price*quantity) /(SELECT 
    ROUND(SUM(quantity * price), 2) AS total_revenue
FROM
    orders_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id) *100,2) as revenue from pizza_types pt
join pizzas p on pt.pizza_type_id = p.pizza_type_id
join orders_details od on p.pizza_id = od.pizza_id
group by pt.category;

-- Analyze the cumulative revenue generated over time.
select order_date,sum(revenue) over (order by order_date) as cum_revenue
from (
select orders.order_date,sum(orders_details.quantity * pizzas.price) as revenue
from orders_details join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = orders_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,Pizza_name,round(revenue,2) as Revenue_Generated from
(select category,Pizza_Name,Revenue,rank() over (partition by category order by Revenue desc) as rn
from
(select pt.category,pt.name as Pizza_Name,sum(od.quantity * p.price) as Revenue
from pizza_types pt
join pizzas p on pt.pizza_type_id = p.pizza_type_id
join orders_details od on p.pizza_id = od.pizza_id
group by pt.category,pt.name) as a) as b
where rn<=3;

