/* This is a data exploration project in SQL Server 2019. It focuses on the following aspects:
	1) Cleaning the dataset
	2) Calucating revenues, orders and products sold as well as top employees and countries
	   in terms of products sold
	3) Creating and using the temporary table (temp table)
	4) Creating and using the common table expression (CTE)
	5) Creating views for visualizations when needed */


-- Retrieve data from the two tables

SELECT * 
FROM northwind_order_details;

SELECT * 
FROM northwind_orders;


-- Update the table: changing the discount value from 0 to 1

UPDATE northwind_order_details
SET discount = 
	CASE 
		WHEN discount = 0 THEN 1 
		ELSE discount 
	END;


-- Calcualte the total revenue

SELECT ROUND(SUM(d.unit_price * d.quantity * (1 - d.discount)), 2) AS TotalRevenue
FROM northwind_order_details AS d;


-- Calcualte the revenue by order

SELECT d.order_id, ROUND(SUM(d.unit_price * d.quantity * (1 - d.discount)), 2) AS revenue
FROM northwind_order_details AS d
GROUP BY d.order_id
ORDER BY revenue DESC;


-- Calcualte the revenue by year

SELECT YEAR(CONVERT(datetime, o.order_date)) AS order_year, 
        ROUND(SUM(d.unit_price * d.quantity * (1 - d.discount)), 2) AS revenue 
    FROM northwind_order_details AS d
    JOIN northwind_orders AS o
        ON d.order_id = o.order_id
    GROUP BY YEAR(CONVERT(datetime, o.order_date));


-- Calcualte the total order

SELECT COUNT(d.order_id) AS TotalOrder
FROM northwind_order_details AS d;


-- Calcualte the number of orders by month

SELECT MONTH(CONVERT(datetime, o.order_date)) AS order_month, 
	COUNT(d.order_id) AS orders_month_count FROM northwind_order_details AS d
JOIN northwind_orders AS o
	ON d.order_id = o.order_id
GROUP BY MONTH(CONVERT(datetime, o.order_date))
ORDER BY orders_month_count DESC;


-- Calculate the number of products sold by employee and year

SELECT o.employee_ID, YEAR(CONVERT(datetime, o.order_date)) AS order_year, 
	COUNT(d.product_id) AS products_sold_count FROM northwind_order_details AS d
JOIN northwind_orders AS o
	ON d.order_id = o.order_id
GROUP BY o.employee_id, YEAR(CONVERT(datetime, o.order_date))
ORDER BY products_sold_count DESC;


-- Calculate top 5 empoloyees who sold the most products in 1998

SELECT TOP 5 o.employee_ID, YEAR(CONVERT(datetime, o.order_date)) AS order_year, 
	COUNT(d.product_id) AS products_sold_count FROM northwind_order_details AS d
JOIN northwind_orders AS o
	ON d.order_id = o.order_id
WHERE YEAR(CONVERT(datetime, o.order_date)) = 1998
GROUP BY o.employee_id, YEAR(CONVERT(datetime, o.order_date))
ORDER BY COUNT(d.product_id) DESC;


-- Calcualte top 5 empoloyees who sold products to most countries

SELECT TOP 5 o.employee_id, COUNT(DISTINCT o.ship_country) AS countries 
FROM northwind_order_details AS d
JOIN northwind_orders AS o 
	ON d.order_id = o.order_id
GROUP BY o.employee_id
ORDER BY COUNT(o.ship_country) DESC;


-- Calculate the top 5 countries the products sold to

SELECT TOP 5 o.ship_country, COUNT(o.order_id) AS OrderCount
FROM northwind_order_details AS d
JOIN northwind_orders AS o 
	ON d.order_id = o.order_id
GROUP BY o.ship_country
order by COUNT(o.order_id) DESC;


/*Create and use a temp table for the number of products sold by employee and year*/

CREATE TABLE #temp_products_sold_by_employee_year (
    employee_ID INT,
    order_year INT,
    products_sold_count INT
);

INSERT INTO #temp_products_sold_by_employee_year 
	(employee_ID, order_year, products_sold_count)
SELECT o.employee_ID, YEAR(CONVERT(datetime, o.order_date)) AS order_year, 
    COUNT(d.product_id) AS products_sold_count 
FROM northwind_order_details AS d
JOIN northwind_orders AS o
    ON d.order_id = o.order_id
GROUP BY o.employee_id, YEAR(CONVERT(datetime, o.order_date));


-- Query data from the temp table

SELECT * 
FROM #temp_products_sold_by_employee_year;


-- Join the temp table with the northwind_orders table to retrieve the order_date data
SELECT t.*, o.order_date
FROM #temp_products_sold_by_employee_year AS t
JOIN northwind_orders AS o 
	ON t.employee_ID = o.employee_ID;


/* Create a CTE for the revenue by year and calculate the total revenue using the CTE */

-- Define the total revenue by year CTE
WITH RevenueByYearCTE AS (
    SELECT YEAR(CONVERT(datetime, o.order_date)) AS order_year, 
        ROUND(SUM(d.unit_price * d.quantity * (1 - d.discount)), 2) AS revenue
    FROM northwind_order_details AS d
    JOIN northwind_orders AS o
        ON d.order_id = o.order_id
    GROUP BY YEAR(CONVERT(datetime, o.order_date)))

-- Calcualte the total revenue using the CTE
SELECT SUM(revenue)
FROM RevenueByYearCTE;


/* Create views for visualizations when needed */

-- Create a view for the revenue by year

CREATE VIEW revenueByYear AS
SELECT YEAR(CONVERT(datetime, o.order_date)) AS order_year, 
	ROUND(SUM(d.unit_price * d.quantity * d.discount), 0) AS TotalRevenue 
FROM northwind_order_details AS d
JOIN northwind_orders AS o
	ON d.order_id = o.order_id
GROUP BY YEAR(CONVERT(datetime, o.order_date))


-- Create a view for the number of orders by month

CREATE VIEW OrdersByMonth AS
SELECT MONTH(CONVERT(datetime, o.order_date)) AS order_month, 
	COUNT(d.order_id) AS orders_month_count FROM northwind_order_details AS d
JOIN northwind_orders AS o
	ON d.order_id = o.order_id
GROUP BY MONTH(CONVERT(datetime, o.order_date))


-- Create a view for the number of products sold by employee and year

CREATE VIEW ProductsSoldByEmployeeYear AS
SELECT o.employee_ID, YEAR(CONVERT(datetime, o.order_date)) AS order_year, 
	COUNT(d.product_id) AS products_sold_count FROM northwind_order_details AS d
JOIN northwind_orders AS o
	ON d.order_id = o.order_id
GROUP BY o.employee_id, YEAR(CONVERT(datetime, o.order_date))
