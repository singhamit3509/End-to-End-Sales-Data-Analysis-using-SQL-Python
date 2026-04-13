CREATE DATABASE sales_project;
SHOW DATABASES;
USE sales_project;

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(20),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);

select * from orders;

#find top 10 highest revenue generating products
SELECT 
product_id,
SUM(sale_price) as sales
FROM orders 
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;


#find top 5 highest selling product in each region 
SELECT * FROM
(
	SELECT 
		region,
		product_id,
		SUM(sale_price) AS sales,
		ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sale_price) DESC) AS rn
	FROM orders
	GROUP BY region, product_id 
) t 
WHERE rn <= 5;    

#find month over month growth comparision for 2022 and 2023 sales 
with cte as (
			SELECT 
				year(order_date) as order_year,
                month(order_date) as order_month,
                SUM(sale_price) as sales
			FROM orders 
            GROUP BY order_year, order_month
)

SELECT 
	order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) as sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) as sales_2023
FROM cte 
GROUP BY order_month
ORDER BY order_month;    

# for each category which month has the highest sale

with cte as (
select 
	category,
	format(order_date,'yyyymm') as order_year_month,
	SUM(sale_price) as sales
FROM orders 
GROUP BY category,format(order_date,'yyyymm')
) 

select * from (
	select * ,
    ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) rn
    from cte
) a
WHERE rn=1;


# which sub category has highest growth by profit in 2023 compare to 2022
with cte as (
	select 
		sub_category,
        year(order_date) as order_year,
        SUM(sale_price) as sales 
	FROM orders 
    GROUP BY sub_category,order_year
),

cte2 as (
	select 
		sub_category,
		SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) as sales_2022,
		SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) as sales_2023
    FROM cte 
    GROUP BY sub_category
)

select * ,
(sales_2022-sales_2023) 
FROM cte2
order by (sales_2022-sales_2023) desc
LIMIT 1;




