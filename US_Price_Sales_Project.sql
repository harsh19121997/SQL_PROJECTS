
------------------------------------------------------------------------ SQL-Project -----------------------------------------------------------------------------
USE project;

SELECT *
FROM sales;

------------------------------------------------------------------------ Data-Cleaning ----------------------------------------------------------------------------
ALTER table sales
DROP COLUMN `item_id`,
DROP COLUMN `bi_st`,
DROP COLUMN `cust_id`,
DROP COLUMN `year`,
DROP COLUMN `month`,
DROP COLUMN `ref_num`,
DROP COLUMN `Name Prefix`,
DROP COLUMN `Middle Initial`,
DROP COLUMN `full_name`,
DROP COLUMN `SSN`,
DROP COLUMN `Phone No.`,
DROP COLUMN `Zip`,
DROP COLUMN `User Name`,
DROP COLUMN `total`,
DROP COLUMN `E Mail`;
ALTER TABLE sales
DROP COLUMN `value`,
DROP COLUMN `Discount_Percent`;
ALTER TABLE sales
DROP COLUMN `Customer since`;
ALTER TABLE SALES
RENAME COLUMN COUNTY TO Country;


-- Count number of records from the data.
SELECT COUNT(*)
FROM SALES; #11389


-- Count the number of columns from the data.
SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_name = 'SALES'; #17


-- Calculate the null values
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS nulls_column1,
  SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS nulls_column2,
  SUM(CASE WHEN `status` IS NULL THEN 1 ELSE 0 END) AS nulls_column3,
  SUM(CASE WHEN qty_ordered IS NULL THEN 1 ELSE 0 END) AS nulls_column4,
  SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS nulls_column5,
  SUM(CASE WHEN discount_amount IS NULL THEN 1 ELSE 0 END) AS nulls_column6,
  SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS nulls_column7,
  SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS nulls_column8,
  SUM(CASE WHEN `First Name` IS NULL THEN 1 ELSE 0 END) AS nulls_column9,
  SUM(CASE WHEN `Last Name` IS NULL THEN 1 ELSE 0 END) AS nulls_column10,
  SUM(CASE WHEN `Gender` IS NULL THEN 1 ELSE 0 END) AS nulls_column11,
  SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS nulls_column12,
  SUM(CASE WHEN `Customer Since` IS NULL THEN 1 ELSE 0 END) AS nulls_column13,
  SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END) AS nulls_column14,
  SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS nulls_column15,
  SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS nulls_column16,
  SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END) AS nulls_column17
FROM sales;  # The data doesn't have any null values present.


-- Create new column by calculating total sales
ALTER TABLE sales
ADD COLUMN total_sales DECIMAL(10, 2) DEFAULT 0.0;
UPDATE sales
SET total_sales = ROUND((qty_ordered * price) - discount_amount, 2);


-- Calculate the average total order value for each month:
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') as `month`,
    AVG(total_sales) as avg_order_value
FROM SALES
GROUP BY `month`
ORDER BY 2 DESC; # March 2021 recorded the highest average sales.


-- Calculate the year by year percentage change in total sales.
with total_value as (select DATE_FORMAT(order_date, '%Y-%m') as year_m, sum(total_sales) as t_value
from sales 
group by year_m)
select t1.year_mon,round(((t1.this_revenue - t1.last_revenue)/t1.this_revenue)*100,2) as per_change
from (select total_value.year_m as year_mon, total_value.t_value as this_revenue, lag(total_value.t_value,1) over() as last_revenue
from total_value) as t1
order by per_change DESC; # March 2021 recorded the highest sales percentage.


-- Calculate the top 10 customers with highest total sales.
SELECT concat(`FIRST NAME`,' ',`LAST NAME`) AS Full_Name,
sum(total_sales) as total_sales
FROM SALES
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- Cities with total sales greater than average total sales.
SELECT CITY, AVG(TOTAL_SALES)
FROM SALES
GROUP BY CITY
HAVING AVG(TOTAL_SALES) > (SELECT AVG(TOTAL_SALES) FROM SALES);


-- Region with highest total sales
SELECT REGION, SUM(Total_sales) Total_sales
FROM SALES
GROUP BY 1
ORDER BY 2 DESC; # Midwest recorded the highest total sales among the regions.

-- Determine the average discount percentage applied to orders in each month.
-- Identify the month with the highest average discount.
SELECT monthname(ORDER_DATE), AVG(DISCOUNT_AMOUNT)
FROM SALES
GROUP BY 1
ORDER BY 2 DESC; #APRIL recorded the highest average discount amount.


-- Calculate the cancellation rate as the percentage of canceled orders compared to the total number of orders.
-- Identify the top 5 category with the highest cancellation rates.
SELECT CATEGORY, 
ROUND((SUM(CASE WHEN STATUS='CANCELED' THEN 1 ELSE 0 END)/COUNT(*))*100,2) AS ORDER_CANCELLATION_PER
FROM SALES
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5; # Others CATEGORY HAS THE HIGHEST CANCELLATION RATE.


-- Find the total value of refunded orders for each item.
-- Identify the top 5 items with the highest total refund value.
SELECT CATEGORY, 
ROUND((SUM(CASE WHEN STATUS='order_refunded' THEN 1 ELSE 0 END)/COUNT(*))*100,2) AS ORDER_REFUNDED_PER
FROM SALES
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5; # Others CATEGORY HAS THE HIGHEST ORDER REFUNDED RATE.


-- Rank the status based on total sales.
SELECT 
    status,
    SUM(total_sales) as total_sales,
    RANK() OVER (ORDER BY SUM(total_sales) DESC) as status_rank
FROM SALES
GROUP BY status
ORDER BY sum(total_sales) DESC; # Customers are more prone to cancel the orders. 


-- Find the date with the highest total order value and the corresponding order details
SELECT *
FROM SALES
WHERE (total_sales) = (
    SELECT MAX(total_sales) as max_total
    FROM SALES
); # 2020-12-23 recorded the highest total order value.


-- Calculate the percentage of total order value contributed by each gender.
WITH GENDER AS (SELECT gender as SEX, SUM(TOTAL_SALES) as sales FROM SALES GROUP BY GENDER),
FINAL AS (select sum(total_sales) AS total_sales from sales)
SELECT 
	GENDER.sex AS GENDER,
    ROUND((GENDER.sales/FINAL.total_sales)*100,2) AS SALES_PER
FROM GENDER, final
ORDER BY 2 DESC; # MALES ARE CONTRIBUTING MORE IN THE TOTAL SALES. 


-- Calculate the total sales percentage based on countries.
WITH COUNTRY AS (SELECT COUNTRY as COUNTRY_NAME, SUM(TOTAL_SALES) as sales FROM SALES GROUP BY COUNTRY),
FINAL AS (select sum(total_sales) AS total_sales from sales)
SELECT 
	COUNTRY.COUNTRY_NAME AS COUNTRY,
    ROUND((COUNTRY.sales/FINAL.total_sales)*100,2) AS SALES_PER
FROM COUNTRY, final
ORDER BY 2 DESC
LIMIT 5;


-- Calculate Gender wise order cancellation rate.
SELECT GENDER, 
ROUND((SUM(CASE WHEN STATUS='canceled' THEN 1 ELSE 0 END)/COUNT(*))*100,2) AS ORDER_CANCELLATION_PER
FROM SALES
GROUP BY 1
ORDER BY 2 DESC; # Males have the highest cancellation rate i.e 30%


-- Find the most preferred payment method among the customers.
SELECT payment_method, count(payment_method) as Order_count
FROM SALES
GROUP BY 1
ORDER BY 2 DESC; # The most preferred payment method happens to be Cash on Delivery.


-- Calculate the count of orders placed by different age-groups.
SELECT T1.age_group, count(T1.age_group) AS order_count
FROM 
(SELECT 
    CASE
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END AS age_group
FROM SALES) as T1
GROUP BY T1.age_group
ORDER BY 2 DESC;


-- Calculate the sum of total orders placed by different age-groups.
SELECT 
    CASE
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END AS age_group,
    sum(total_sales) AS Total_sales
FROM SALES
GROUP BY 1
ORDER BY 2 DESC;
