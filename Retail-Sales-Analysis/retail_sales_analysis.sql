-- 1. Database Setup
CREATE DATABASE p1_retail_db;

USE p1_retail_db;

CREATE TABLE retail_sales
(
	transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(10),
    age INT,
    category VARCHAR(40),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

-- 2. Data Exploration & Cleaning

-- Record Count: Determine the total number of records in the dataset.
SELECT COUNT(*) FROM retail_sales;

-- Customer Count: Find out how many unique customers are in the dataset.
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;

-- Category Count: Identify all unique product categories in the dataset.
SELECT category
FROM retail_sales
GROUP BY category;

-- OR
SELECT DISTINCT category
FROM retail_sales;

-- Null Value Check: Check for any null values in the dataset and delete records
-- with missing data.
SELECT *
FROM retail_sales
WHERE 
	sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR
    gender IS NULL OR age IS NULL OR category IS NULL OR quantity IS NULL OR
    price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;
    
DELETE FROM retail_sales
WHERE
	sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR
    gender IS NULL OR age IS NULL OR category IS NULL OR quantity IS NULL OR
    price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;
      

-- 3. Data Analysis & Findings
-- 3.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'.
SELECT *
FROM retail_sales
WHERE
	sale_date = '2022-11-05';
    
-- 3.2 Write a SQL query to retrieve all transactions where the category
-- is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:

SELECT DISTINCT quantity
FROM retail_sales;

SELECT *
FROM retail_sales
WHERE 
	category = 'Clothing' AND quantity >= 4
HAVING
	MONTH(sale_date) = 11 AND YEAR(sale_date) = 2022;
    
-- OR (ERROR: TO_CHAR() does not exist)
SELECT *
FROM retail_sales
WHERE
	category = 'Clothing'
    AND
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantity >= 4;
    
-- ERROR: Syntax error
SELECT *
FROM retail_sales
WHERE
	category = 'Clothing'
    AND
	'2022-11%' LIKE STRING(sale_date)
    AND
    quantity >= 4;
    
    
-- 3.3 Write a SQL query to calculate the total sales (total_sale) for each category:
SELECT category, 
	SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;

-- 3.4 Write a SQL query to find the average age of customers who purchased items
-- from the "Beauty" category:
SELECT ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE 
	category = 'Beauty';
    
-- Average customer age by category.
SELECT category, 
	ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
GROUP BY category
;
    
SELECT ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
GROUP BY category
HAVING 
	category = 'Beauty';
    
-- 3.5 Write a SQL query to find all transactions where the total_sale is greater 
-- than 1000:
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- 3.6 Write a SQL query to find the total number of transactions (transaction_id)
-- made by each gender in each category:
SELECT gender,
category,
COUNT(transactions_id) AS total_txns
FROM retail_sales
GROUP BY gender, category
ORDER BY 2;

-- 3.7 Write a SQL query to calculate the average sale for each month. Find out best
-- selling month in each year:
SELECT DISTINCT(YEAR(sale_date)),
MONTH(sale_date),
AVG(total_sale) AS avg_sale
FROM retail_sales
GROUP BY
	YEAR(sale_date), MONTH(sale_date)
ORDER BY 3 DESC
;

SELECT 
	year,
	month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank_
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank_ = 1;


-- 3.8 Write a SQL query to find the top 5 customers based on the highest total sales:
SELECT customer_id,
SUM(total_sale) AS net_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY net_sales DESC
LIMIT 5;


-- 3.9 Write a SQL query to find the number of unique customers who purchased items
-- from each category:
SELECT COUNT(DISTINCT(customer_id)) AS num_unique_customer,
category
FROM retail_sales
GROUP BY 2;


-- 3.10 Write a SQL query to create each shift and number of orders (Example Morning
-- < 12, Afternoon Between 12 & 17, Evening > 17):
SELECT 
	CASE 
		WHEN HOUR(sale_time) < 12 THEN "Morning"
		WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN "Afternoon"
		WHEN HOUR(sale_time) > 17 THEN "Evening"
        -- ELSE "Evening"
	END
    AS shift,
    COUNT(transactions_id) AS num_orders
FROM retail_sales
GROUP BY 1
;

-- Using CTE
WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders  
FROM hourly_sale
GROUP BY shift;

SELECT *
FROM retail_sales;
