## E-Commerce Sale Analysis
There are 275 rows in the dataset.

We have excel file in .xlsx extension, since MySQL cannot load .xlsx file, so we convert it to .csv file using python script `convert_xlsx_2_csv.py`. And then only load the data into the MySQL.

Dataset: https://docs.google.com/spreadsheets/d/1vCaA0TM_mwzkEFcK3HYfRQnYPkeVVpm7/edit?usp=sharing&ouid=111642879812805231977&rtpof=true&sd=true

Some of the questions we are going to solve are as follows:

#### How many products were created in the year 2018?
```
SELECT COUNT(*)
FROM ecommerce_table
WHERE YEAR(item_creation_time_modified) = "2018";
```
Output:
```
219
```

#### Find the top 3 categories that have the greatest number of unique cross border products?
```
SELECT category, SUM(cb_option) AS total_cb_option
FROM ecommerce_table
GROUP BY category
ORDER BY total_cb_option DESC
LIMIT 3;
```
Output:
```
# category, total_cb_option
'Mobile & Gadgets', '126'
'Jewellery & Accessories', '31'
'Women\'s Apparel', '30'
```

#### Find the top 3 shops with highest revenue?
```
SELECT shopid,
    price*sold_count as Revenue
FROM ecommerce_table
GROUP BY shopid
ORDER BY Revenue DESC
LIMIT 3;
```
Output:
```
# category, total_cb_option
'Mobile & Gadgets', '126'
'Jewellery & Accessories', '31'
'Women's Apparel', '30'
```

#### Find the top 3 shops with highest revenue?
```
SELECT shopid,
SUM(price*sold_count) OVER(PARTITION BY shopid) AS revenue
FROM ecommerce_table
ORDER BY revenue DESC
LIMIT 3;
```
Output:
```
# shopid, total_revenue
'11272000', '172.31999588012695'
'26451002', '70.7999997138977'
'5844001', '42'
```

#### Identify duplicated listings within each shop and mark those duplicated listings  with True Otherwise False in a separate column called is_duplicated (If listing A and B in shop S have the exactly same product title, product detailed description, and price, both listing A and B are considered as duplicated listings)

Approach: To identify duplicated listings within each 'shopid', we need to check if multiple rows in the same shop have the same 'item_name', 'item_description', and 'price'. If so, we mark them as duplicated.
```
WITH DuplicateCheck AS (
	SELECT
		shopid,
        item_name,
        item_description,
        price,
        sold_count,
        COUNT(*) OVER (PARTITION BY shopid, item_name, item_description, price) AS duplicate_count,
        itemid  -- keep track of the unique listing ID
	FROM ecommerce_table
)
SELECT
	d.*,
    CASE
		WHEN duplicate_count > 1 THEN TRUE
        ELSE FALSE
	END AS is_duplicated
FROM DuplicateCheck d;
```

#### Find duplicated listings that have less than 2 'sold_count' and store in an excel file called 'duplicated_listings.xlsx'.
Approach: 
1. Identify duplicated listings within each shop where 'item_name', 'item_description', and 'price' are the same.
2. Filter listings where 'sold_count < 2'.
3. Export the result to an excel file ('duplicated_listings.xlsx').

First check secure file privileged directory
```
SHOW VARIABLES LIKE 'secure_file_priv';
```
Outputs:
```
# Variable_name, Value
'secure_file_priv', 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\'
```
then,
```
SELECT 'itemid', 'shopid', 'item_name', 'item_description', 'price', 'sold_count'
UNION ALL
SELECT 
    itemid, 
    shopid, 
    item_name, 
    item_description, 
    price, 
    sold_count
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/duplicated_listings.csv'
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
        FROM ecommerce_table
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
```

Then, the .csv file is easily converted to .xlsx file using python script `csv_2_xlsx.py`.

####  Find the number of products that have more than 3 variations.
```
SELECT *
FROM (
    SELECT *,
        (LENGTH(item_variation) - LENGTH(REPLACE(item_variation, ',', '')) + 1) AS variation_count
    FROM ecommerce_table
) AS sub_query
WHERE variation_count > 3;
```

#### Find the average time between every successive 'item_creation_time'.
```
SELECT AVG(time_diff) / 60 AS avg_time_diff_minutes
FROM (
    SELECT TIMESTAMPDIFF(SECOND, item_creation_time, LEAD(item_creation_time) 
                         OVER (ORDER BY item_creation_time)) AS time_diff
    FROM ecommerce_table
) AS subquery;
```
Output:
```
# avg_time_diff_minutes
'5180.95079075'
```