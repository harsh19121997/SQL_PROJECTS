Use zomato_project;

-- 1.what is total amount each customer spent on zomato ?
SELECT U.userid, S.Name, sum(P.price)
FROM users as U
LEFT JOIN sales AS S
ON U.userid = S.userid
LEFT JOIN product as P
ON S.product_id = P.product_id
GROUP BY 1, 2
ORDER BY 1 ASC;

-- 2.How many days has each customer visited zomato?
SELECT userid, Name, count(Name) as Visited_Counts
FROM SALES
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 3.what was the first product purchased by each customer?
SELECT userid, Name, Product_Name FROM
(SELECT S.userid AS userid, S.Name AS Name, P.product_name AS Product_Name,
DENSE_RANK() OVER(PARTITION BY S.Name ORDER BY S.created_date ASC) AS ranked_dates
FROM sales as S
INNER JOIN product as P
ON S.product_id = P.product_id) AS T1
WHERE T1.ranked_dates = 1;


-- 4.what is most purchased item on menu & how many times was it purchased by all customers ?
SELECT S.name, COUNT(P.product_id) AS Num_of_time_ordered, P.product_name
FROM sales AS S
INNER JOIN product as P
ON S.product_id = P.product_id
WHERE P.product_id = (SELECT PRODUCT_ID FROM SALES GROUP BY 1 ORDER BY COUNT(PRODUCT_ID) DESC LIMIT 1)
GROUP BY 1,3
ORDER BY 2 DESC;


-- 5. which item was purchased first by customer after they become a GOLD member ?
SELECT userid, gold_signup_date, Name, created_date, Product_Name
FROM
(SELECT G.userid AS userid, G.gold_signup_date AS gold_signup_date , S.name AS Name, S.created_date AS created_date, P.product_name AS Product_Name, 
DENSE_RANK() OVER(PARTITION BY S.name ORDER BY S.created_date ASC) AS ranked_dates
FROM gold_users AS G
INNER JOIN sales AS S
ON G.userid = S.userid
INNER JOIN product as P
ON S.product_id = P.product_id
WHERE S.created_date > G.gold_signup_date
ORDER BY 1) AS T1
WHERE T1.ranked_dates = 1;


-- 6. which item was purchased just before the customer became a member?
SELECT userid, gold_signup_date, Name, created_date, Product_Name
FROM
(SELECT G.userid AS userid, G.gold_signup_date AS gold_signup_date , S.name AS Name, S.created_date AS created_date, P.product_name AS Product_Name, 
DENSE_RANK() OVER(PARTITION BY S.name ORDER BY S.created_date DESC) AS ranked_dates
FROM gold_users AS G
INNER JOIN sales AS S
ON G.userid = S.userid
INNER JOIN product as P
ON S.product_id = P.product_id
WHERE S.created_date < G.gold_signup_date
ORDER BY 1) AS T1
WHERE T1.ranked_dates = 1;


-- 7. what is total orders and amount spent for each member before they become a member?
SELECT G.userid AS userid, S.name AS Name,
COUNT(S.product_id) AS  Order_Count, SUM(P.price) AS Total_Amt
FROM gold_users AS G
INNER JOIN sales AS S
ON G.userid = S.userid
INNER JOIN product as P
ON S.product_id = P.product_id
WHERE S.created_date < G.gold_signup_date
GROUP BY 1,2
ORDER BY 1;

-- 8. Display the top 3 users who made the highest total purchases. Include their names, total purchases, and ranks.
SELECT u.userid, s.name, SUM(p.price) AS total_purchases,
RANK() OVER (ORDER BY SUM(p.price) DESC) AS purchase_rank
FROM users u
JOIN sales s ON u.userid = s.userid
JOIN product p ON s.product_id = p.product_id
GROUP BY u.userid, s.name
ORDER BY purchase_rank
LIMIT 3;

-- 9. Retrieve a list of age groups with their respective total sales amount.
SELECT 
    CASE
        WHEN age BETWEEN 25 AND 30 THEN '25-30'
        WHEN age BETWEEN 31 AND 35 THEN '31-35'
        WHEN age BETWEEN 36 AND 40 THEN '36-40'
        WHEN age BETWEEN 41 AND 45 THEN '41-45'
        END AS age_group,
        sum(P.PRICE) AS total_sales
FROM SALES AS S1
JOIN PRODUCT AS P
ON S1.PRODUCT_ID = P.PRODUCT_ID
GROUP BY 1
ORDER BY 2 DESC;

-- 10. Find the total sales year wise.
SELECT YEAR(s.created_date) AS sales_year, SUM(p.price) AS total_price
FROM sales AS s
JOIN product AS p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2;

-- 11. For each user, calculate the time difference between consecutive purchases. Display user ID, name, purchase date, and the time difference.
SELECT S.userid, s.name, s.created_date, 
LAG(s.created_date,1,s.created_date) OVER (PARTITION BY S.userid ORDER BY s.created_date) AS previous_purchase_date,
DATEDIFF(s.created_date, LAG(s.created_date,1,s.created_date) OVER (PARTITION BY S.userid ORDER BY s.created_date)) AS time_difference
FROM sales s
ORDER BY S.userid;

-- 12. Calculate the monthly growth rate of total sales. Display the month, total sales, and the percentage growth compared to the previous month.
SELECT DATE_FORMAT(s.created_date, '%Y-%m') AS `year_month`, SUM(p.price) AS total_sales,
100 * (SUM(p.price) - LAG(SUM(p.price)) OVER (ORDER BY DATE_FORMAT(s.created_date, '%Y-%m'))) / LAG(SUM(p.price)) OVER (ORDER BY DATE_FORMAT(s.created_date, '%Y-%m')) AS growth_rate
FROM sales s
JOIN product p 
ON s.product_id = p.product_id
GROUP BY `year_month`
ORDER BY `year_month`;
