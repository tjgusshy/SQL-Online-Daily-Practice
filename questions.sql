{# Find the customers with the highest daily total order cost between 2019-02-01 and 2019-05-01. If a customer had more than one order on a certain day, sum the order costs on a daily basis. Output each customer's first name, total cost of their items, and the date. If multiple customers tie for the highest daily total on the same date, return all of them.


For simplicity, you can assume that every first name in the dataset is unique.

Tables
customers
orders #}



SELECT 
    c.first_name,
    o.order_date,
    SUM(o.total_order_cost) AS total_cost
FROM orders o
JOIN customers c 
    ON c.id = o.cust_id
WHERE o.order_date BETWEEN '2019-02-01' AND '2019-05-01'
GROUP BY c.first_name, o.order_date
QUALIFY RANK() OVER (PARTITION BY o.order_date ORDER BY SUM(o.total_order_cost) DESC) = 1;


Day 2

SELECT DISTINCT
    company_name,
    COUNT(CASE WHEN year = 2020 THEN product_name END) 
        OVER (PARTITION BY company_name) 
        - 
    COUNT(CASE WHEN year = 2019 THEN product_name END) 
        OVER (PARTITION BY company_name) AS net_difference
FROM car_launches;

Calculate the net change in the number of products launched by companies in 2020 compared to 2019. Your output should include the company names and the net difference.
(Net difference = Number of products launched in 2020 - The number launched in 2019.)

Table
car_launches
company_name:
text
product_name:
text
year:
bigint

SELECT DISTINCT
    company_name,
    COUNT(CASE WHEN year = 2020 THEN product_name END) 
        OVER (PARTITION BY company_name) 
        - 
    COUNT(CASE WHEN year = 2019 THEN product_name END) 
        OVER (PARTITION BY company_name) AS net_difference
FROM car_launches;

Calculates the difference between the highest salaries in the marketing and engineering departments. Output just the absolute difference in salaries.

Tables
db_employee
db_dept

WITH dept_max AS (
  SELECT 
    R.department,
    MAX(L.salary) AS max_salary
  FROM db_employee L
  INNER JOIN db_dept R ON L.department_id = R.id
  WHERE R.department IN ('marketing', 'engineering')
  GROUP BY R.department
)
SELECT 
  ABS(
    MAX(CASE WHEN department = 'marketing' THEN max_salary END)
    -
    MAX(CASE WHEN department = 'engineering' THEN max_salary END)
  ) AS abs_salary_difference
FROM dept_max;
Compare the total number of comments made by users in each country during December 2019 and January 2020. For each month, determine how each country ranks based on its total number of comments (with countries having the same total sharing the same rank). Return the names of the countries whose rank improved from December to January (i.e., their rank number decreased).

Tables
fb_comments_count
fb_active_users

WITH monthly_comments AS (
    SELECT u.country,
           date_trunc('month', c.created_at)::date AS month_start,
           SUM(c.number_of_comments) AS total_comments
    FROM fb_comments_count AS c
    JOIN fb_active_users AS u ON c.user_id = u.user_id
    WHERE c.created_at >= '2019-12-01'
      AND c.created_at < '2020-02-01'
    GROUP BY u.country,
             date_trunc('month', c.created_at)::date
),
december AS (
    SELECT country,
           total_comments
    FROM monthly_comments
    WHERE month_start = '2019-12-01'
),
january AS (
    SELECT country,
           total_comments
    FROM monthly_comments
    WHERE month_start = '2020-01-01'
),
december_rank AS (
    SELECT country,
           total_comments,
           DENSE_RANK() OVER (
               ORDER BY total_comments DESC
           ) AS dec_rank
    FROM december
),
january_rank AS (
    SELECT country,
           total_comments,
           DENSE_RANK() OVER (
               ORDER BY total_comments DESC
           ) AS jan_rank
    FROM january
),
rank_compare AS (
    SELECT d.country,
           d.dec_rank,
           j.jan_rank,
           d.total_comments AS dec_comments,
           j.total_comments AS jan_comments
    FROM december_rank d
    JOIN january_rank j USING (country)
)
SELECT country
FROM rank_compare
WHERE dec_rank > jan_rank
ORDER BY dec_rank;

 

 We have a table with employees and their salaries, however, some of the records are old and contain outdated salary information. Find the current salary of each employee assuming that salaries increase each year. Output their id, first name, last name, department ID, and current salary. Order your list by employee ID in ascending order.

Table
ms_employee_salary

department_id:
bigint
first_name:
text
id:
bigint
last_name:
text
salary:
bigint

WITH ranked AS (
    SELECT 
        id,
        first_name,
        department_id,
        last_name,
        salary,
        ROW_NUMBER() OVER (PARTITION BY id ORDER BY salary DESC, department_id DESC) AS rn
    FROM ms_employee_salary
)
SELECT 
    id,
    first_name,
    department_id,
    last_name,
    salary
FROM ranked
WHERE rn = 1
ORDER BY id;
