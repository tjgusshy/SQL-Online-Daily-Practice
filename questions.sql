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


 