---Write a SQL query to find the second highest salary from the employees table.
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

--- Window functions
--- Calculate the running total of sales for each product category
SELECT product_category, sales_amount
sum(sales_amount) over (partition by product_category order by sales_date) as running_total
from sales
group by product_category, sales_date;

--- Subqueries and  CTEs (Common Table Expressions)
--- Fetch customers who made more than 3 purchases last month
With monthly_purchases as (
    SELECT customer_id, count(*) as purchase_count
    from transactions
    WHERE purchase_date between '2023-08-01' AND '2023-08-31'
    group by customer_id
)
SELECT customer_id
from monthly_purchases
WHERE purchase_count > 3;

--- join
-- Fetch all orders along with customer information
select o.order_id, c.customer_name, o.amount
from Orders o
join Customers c on o.customer_id = c.customer_id

--- Data Transformation and Aggregation
-- Aggregating sales data by year and category
SELECT EXTRACT(YEAR FROM sale_date) AS year, product_category, SUM(sales_amount) AS total_sales
FROM sales
GROUP BY year, product_category;

-----------------------------
-----------------------------
