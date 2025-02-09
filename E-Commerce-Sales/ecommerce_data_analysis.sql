CREATE DATABASE daraz_data;

USE daraz_data;

CREATE TABLE daraz_table (
	itemid INT,
    shopid INT,
    item_name VARCHAR(200),
    item_description TEXT,
    item_variation TEXT,
    price FLOAT,
    stock INT,
    category VARCHAR(100),
    cb_option INT,
    is_preferred INT,
    sold_count INT,
    item_creation_time_modified DATE
);

SELECT * FROM daraz_table;

SELECT COUNT(*) 
FROM daraz_table;

-- How many products were created in the year 2018?
SELECT COUNT(*)
FROM daraz_table
WHERE YEAR(item_creation_time_modified) = "2018";

-- Find the top 3 categories that have the greatest number of unique cross border products?
SELECT category, SUM(cb_option) AS total_cb_option
FROM daraz_table
GROUP BY category
ORDER BY total_cb_option DESC
LIMIT 3;


-- Find the top 3 shops with highest revenue?
SELECT shopid,
price*sold_count as Revenue
FROM daraz_table
GROUP BY shopid
ORDER BY Revenue DESC
LIMIT 3;

SELECT shopid,
SUM() OVER(PARTITION BY shopid) AS revenue
FROM daraz_table;

SELECT shopid,
SUM(price*sold_count) OVER (PARTITION BY shopid) AS revenue
FROM daraz_table
ORDER BY revenue DESC
LIMIT 3
;

SELECT shopid, SUM(price*sold_count) AS total_revenue
FROM daraz_table
GROUP BY shopid
ORDER BY total_revenue DESC
LIMIT 3
;

SELECT * FROM daraz_table;

SELECT shopid, (price*sold_count) AS revenue
FROM daraz_table;

-- 4. Identify duplicated listings within each shop and mark those duplicated listings 
-- with True Otherwise False in a separate column called is_duplicated (If listing A and B 
-- in shop S have the exactly same product title, product detailed description, and price, 
-- both listing A and B are considered as duplicated listings)

-- Solution:
-- To identiy duplicated listings within each `shopid`, we need to check if multiple rows in the
-- same shop have the same `item_name`, `item_description`, and `price`. 
-- If so, we mark them as duplicated.
WITH DuplicateCheck AS (
	SELECT
		shopid,
        item_name,
        item_description,
        price,
        sold_count,
        COUNT(*) OVER (PARTITION BY shopid, item_name, item_description, price) AS duplicate_count,
        itemid  -- keep track of the unique listing ID
	FROM daraz_table
)
SELECT
	d.*,
    CASE
		WHEN duplicate_count > 1 THEN TRUE
        ELSE FALSE
	END AS is_duplicated
FROM DuplicateCheck d;

-- Find duplicated listings that have less than 2 sold_count and store in an excel 
-- file called “duplicated_listings.xlsx”
-- Solution:
-- 1. Identify duplicated listings within each shop where `item_name`, `item_description`, and
-- `price` are the same.
-- 2. Filter listings where `sold_count < 2`.
-- 3. Export the result to an Excel file (`duplicated_listings.xlsx`).
WITH DuplicateCheck AS (
	SELECT
		shopid,
        item_name,
        item_description,
        price,
        sold_count,
        COUNT(*) OVER (PARTITION BY shopid, item_name, item_description, price) AS duplicate_count,
        itemid  -- keep track of the unique listing ID
	FROM daraz_table
)
SELECT
	d.*
FROM DuplicateCheck d
WHERE sold_count < 2 AND duplicate_count > 1;

-- Export Query (MySQL Server with FILE privileges)
SELECT 
    itemid, 
    shopid, 
    item_name, 
    item_description, 
    price, 
    sold_count
INTO OUTFILE 'C:\\ProgramData\\MySQL\\duplicated_listings.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
FROM (
    WITH DuplicateCheck AS (
        SELECT 
            itemid,
            shopid, 
            item_name, 
            item_description, 
            price,
            sold_count,
            COUNT(*) OVER (PARTITION BY shopid, item_name, item_description, price) AS duplicate_count
        FROM daraz_table
    )
    SELECT 
        itemid, 
        shopid, 
        item_name, 
        item_description, 
        price, 
        sold_count
    FROM DuplicateCheck
    WHERE duplicate_count > 1 AND sold_count < 2
) AS subquery;

SELECT *
FROM daraz_table;

SELECT *
	FROM (
		SELECT *,
			(LENGTH(item_variation) - LENGTH(REPLACE(item_variation, ',', '')) + 1) AS variation_count
		FROM daraz_table
    ) AS sub_query
WHERE variation_count > 3;


SELECT TIME(item_creation_time_modified)
FROM daraz_table;


# Creating another table to store column 'item_creation_time' with proper datatype acceptable
# to the MySQL.
USE daraz_data;

CREATE TABLE daraz_table2 (
	itemid BIGINT,
    shopid BIGINT,
    item_name TEXT,
    item_description TEXT,
    item_variation TEXT,
    price FLOAT,
    stock INT,
    category VARCHAR(200),
    cb_option INT,
    is_preferred INT,
    sold_count INT,
    item_creation_time DATETIME
);

SELECT *
FROM daraz_table2;

SELECT COUNT(*)
FROM daraz_table2;

SELECT 
    AVG(TIMESTAMPDIFF(SECOND, item_creation_time, LEAD(item_creation_time) OVER (ORDER BY item_creation_time))) AS avg_time_diff_seconds
FROM daraz_table2
WHERE item_creation_time IS NOT NULL;

SELECT 
    AVG(TIMESTAMPDIFF(SECOND, item_creation_time, LEAD(item_creation_time) OVER (ORDER BY item_creation_time))) / 60 AS avg_time_diff_minutes
FROM daraz_table2
WHERE item_creation_time IS NOT NULL;

SELECT AVG(time_diff) / 60 AS avg_time_diff_minutes
FROM (
    SELECT TIMESTAMPDIFF(SECOND, item_creation_time, LEAD(item_creation_time) 
                         OVER (ORDER BY item_creation_time)) AS time_diff
    FROM daraz_table2
) AS subquery;

