## This is SQL Data Analysis Project

We have dataset `Retail Sales Analysis.csv` and we are going to answer some of the questions created by ourself using SQL in MySQL database management system.

Glimplse of the dataset.

![alt text](<glimpse of the dataset.png>)

### 1. Database Setup
First we have to create a database in MySQL Workbench. The database name we kept is `p1_retail_db`.
```
CREATE DATABASE p1_retail_db;
```
Then we use that database using following SQL command.
```
USE p1_retail_db;
```

### 2. Creating database table
We have columns: 
```transactions_id	sale_date	sale_time	customer_id	gender	age	category	quantiy	price_per_unit	cogs	total_sale``` 
in the .csv file. So, the  database table is created accordingly with proper datatype. The table name is `retail_sales`.

```
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
```

### 3. Data Exploration and Cleaning

#### Determine the total number of records in the dataset.
```
SELECT COUNT(*) FROM retail_sales;
```
There are 1987 records in the dataset.

#### Find out how many unique customers are in the dataset.
```
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
```
There are 155 unique customers.


#### Category Count: Identify all unique product categories in the dataset.
```
SELECT category
FROM retail_sales
GROUP BY category;
```
Unique categories are:

```
Beauty
Clothing
Electronics
```

#### Null Value Check: Check for any null values in the dataset and delete records with missing data.
```
SELECT *
FROM retail_sales
WHERE 
	sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR
    gender IS NULL OR age IS NULL OR category IS NULL OR quality IS NULL OR
    price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;
```

Then deleting the any Null values from the database.
```
DELETE FROM retail_sales
WHERE
	sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR
    gender IS NULL OR age IS NULL OR category IS NULL OR quantity IS NULL OR
    price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;
```

### 4. Data Analysis and Findings

#### Retrieve all columns for sales made on '2022-11-05'.
```
SELECT *
FROM retail_sales
WHERE
	sale_date = '2022-11-05';
```

#### Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022.

```
SELECT *
FROM retail_sales
WHERE 
	category = 'Clothing' AND quantity >= 4
HAVING
	MONTH(sale_date) = 11 AND YEAR(sale_date) = 2022;
```

#### Calculate the total sales for each category.
```
SELECT category, 
	SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;
```

#### Find the average age of customers who purchased items from the 'Beauty' category.
```
SELECT ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE 
	category = 'Beauty';
```

#### Find all transactions where the total_sale is greater than 1000.
```
SELECT *
FROM retail_sales
WHERE total_sale > 1000;
```

#### Find the total number of transactions (transaction_id) made by each gender in each category.
```
SELECT gender,
    category,
    COUNT(transactions_id) AS total_txns
FROM retail_sales
GROUP BY gender, category
ORDER BY 2;
```

#### Calculate the average sale for each month and find out best selling month in each year.
```
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
```

#### Find the top 5 customers based on the highest total sales
```
SELECT customer_id,
    SUM(total_sale) AS net_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY net_sales DESC
LIMIT 5;
```

#### Find the number of unique customers who purchased items from each category.
```
SELECT COUNT(DISTINCT(customer_id)) AS num_unique_customer,
    category
FROM retail_sales
GROUP BY 2;
```

Output:
```
# num_unique_customer, category
'141', 'Beauty'
'149', 'Clothing'
'144', 'Electronics'

```

#### Create shifts and number of orders in each shifts 
```
(Example: Morning < 12, 
          Afternoon Between 12 & 17,
          Evenging > 17 )
```

```
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
```
OR using CTE

```
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
```

Output:
```
Evening	1062
Morning	548
Afternoon 377
```