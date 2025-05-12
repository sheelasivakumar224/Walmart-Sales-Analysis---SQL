Use walmart;

SELECT * FROM walmart_01;

-- Question 1:
-- Which 3 branches are underperforming in terms of revenue?

SELECT branch, SUM(Total_price) as Revenue
FROM walmart_01
GROUP BY 1
ORDER BY 2
LIMIT 3;

-- Question 2:
-- FIND DIFFERENT payment methods and number if transaction, number of qty sold

SELECT payment_method, COUNT(*) as no_of_transaction, SUM(quantity) as qty_sold
FROM walmart_01
GROUP BY payment_method;

-- Question 3:
-- IDENTIFY THE HIGHEST-RATED CATEGORY IN EACH BRANCH, DISPLAYING THE BRANCH, CATEGORY, AVG RATING

SELECT branch, category, avg_rating
FROM (
	SELECT branch, category, avg(rating) as avg_rating, RANK() OVER(PARTITION BY branch ORDER BY branch, avg(rating) DESC) AS rnk
	FROM walmart_01
	GROUP BY 1, 2
) AS ranked
WHERE rnk=1;

-- Question 4:
-- Identify the busiest day for each branch based in the number of transactions

SELECT branch, day_name, transaction_count 
FROM (
SELECT branch, 
DATE_FORMAT(STR_TO_DATE(date , '%d/%m/%y'), '%W') AS day_name,
count(*) as transaction_count, RANk() OVER(PARTITION BY branch ORDER BY count(*) DESC) as rnk
FROM walmart_01
GROUP BY branch, day_name) as ranked 
WHERE rnk = 1;

-- Question 5:
-- Calculate the total quantity of items sold per payment method. List payment_method and total quantity

SELECT payment_method, SUM(quantity) as total_quantity
FROM walmart_01
GROUP BY payment_method
ORDER BY total_quantity DESC;

-- Question 6:
-- Determine the average, minimum and maximum rating of Category for each city, List the city, average_rating, min_rating, and max_rating

SELECT city, category, avg(rating) as Average_rating, min(rating) as Minimum_rating, max(rating) as Maximum_rating
FROM walmart_01
GROUP BY 1, 2
ORDER BY 1;

-- Question 7:
-- Calculate the total profit for each category

SELECT category,SUM(Total_price) as Total_price, ROUND(SUM(Total_price * profit_margin),2)as Total_profit
FROM walmart_01
GROUP BY category
ORDER BY Total_profit DESC;

-- Question 8:
-- Determine the most common payment method for each branch

SELECT branch, payment_method as 'preferred payment method' FROM (
SELECT branch, payment_method, count(*) as transaction_count, RANK() OVER(partition by branch order by count(*) DESC) as rnk
FROM walmart_01
GROUP BY 1,2) as ranked
WHERE rnk = 1 ;

-- Question 9:
-- Categorize sales into Morning, Afternoon, and Evening shifts, Find out each of the shifts and number of invoices

SELECT branch, CASE WHEN HOUR(TIME(time))<12 then 'Morning' 
				  WHEN HOUR(TIME(time)) BETWEEN 12 and 17 then 'Afternoon'
                  ELSE 'Evening'END as shifts,
                  count(*) as total_invoices
FROM walmart_01
group by branch, shifts
order by branch;

-- Question 10:
-- Identify 5 branch with highest decrese ratio in revenue compare to last year (Current year 2023 and last year 2022)
-- rde (Revenue decrease ratio) = last_rev-cr_rev/last_rev*100

SELECT branch, SUM(CASE WHEN year = 2022 THEN revenue ELSE 0 END) last_yr_revenue, 
SUM(CASE WHEN year = 2023 THEN revenue ELSE 0 END) as current_yr_revenue
FROM(
SELECT branch, DATE_FORMAT(STR_TO_DATE(date , '%d/%m/%y'), '%Y') AS year, round(sum(unit_price*Total_price),2) as revenue
FROM walmart_01
GROUP BY 1,2
HAVING year in (2022, 2023)
) as extracted
GROUP BY 1
ORDER BY 1;


WITH revenue_2022 AS(
	SELECT branch, SUM(Total_price) as revenue
    FROM walmart_01
    WHERE YEAR(str_to_date(date, '%d/%m/%y')) = 2022
    GROUP BY branch
),
revenue_2023 AS(
	SELECT branch, SUM(Total_price) as revenue
    FROM walmart_01
    WHERE YEAR(str_to_date(date, '%d/%m/%y')) = 2023
    GROUP BY branch
)
SELECT revenue_2022.branch, revenue_2022.revenue as last_yr_revenue, revenue_2023.revenue as cu_yr_revenue,
round(((revenue_2022.revenue - revenue_2023.revenue)/revenue_2022.revenue)*100,2) as rde
FROM revenue_2022 
JOIN revenue_2023
ON revenue_2022.branch = revenue_2023.branch
WHERE revenue_2022.revenue > revenue_2023.revenue
ORDER BY rde DESC
LIMIT 5;