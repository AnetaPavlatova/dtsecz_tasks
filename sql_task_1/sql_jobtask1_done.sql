--TASK 1--
--Write query which will show those customers with contacts and with orders (all columns)


SELECT cu.*,
	o.order_id,
    o.item,
    o.order_value,
    o.order_currency,
    o.order_date,
    co.address,
    co.city,
    co.phone_number,
    co.email
FROM customers AS cu
INNER JOIN orders as o
ON cu.customer_id = o.customer_id
INNER JOIN contacts as co
ON cu.customer_id = co.customer_id
ORDER BY customer_id;


--TASK 2--
-- There is  suspision that some orders were wrongly inserted more times. Check if there are any duplicated orders. If so, return unique duplicates with the following details:
-- first name, last name, email, order id and item

-- Checking if there are any duplicate orders:

SELECT order_id, item, COUNT(order_id) as amount_orders
FROM orders
GROUP BY order_id, item
HAVING amount_orders > 1;

-- YES, there are 2 duplicate orders. Now, I will find more details about the duplicate orders:

SELECT cu.first_name,
	cu.last_name,
    co.email,
    o.order_id,
    o.item,
    COUNT(o.order_id) AS num_orders
FROM orders AS o
LEFT JOIN customers AS cu
ON cu.customer_id = o.customer_id
JOIN contacts as co
ON cu.customer_id = co.customer_id
GROUP BY cu.first_name, cu.last_name, co.email, o.order_id
HAVING num_orders > 1;


--TASK 3--
-- As you found out, there are some duplicated order which are incorrect, adjust query so it does following:
-- Show first name, last name, email, order id and item
-- Does not show duplicates
-- Order result by customer last name

SELECT DISTINCT cu.first_name,
	cu.last_name,
    co.email,
    o.order_id,
    o.item
FROM orders AS o
JOIN customers AS cu
ON cu.customer_id = o.customer_id
JOIN contacts as co
ON cu.customer_id = co.customer_id
ORDER BY cu.last_name;


--TASK 4--
--Our company distinguishes orders to sizes by value like so:
--order with value less or equal to 25 euro is marked as SMALL
--order with value more than 25 euro but less or equal to 100 euro is marked as MEDIUM
--order with value more than 100 euro is marked as BIG
--Write query which shows only three columns: full_name (first and last name divided by space), order_id and order_size
--Make sure the duplicated values are not shown
--Sort by order ID (ascending)

SELECT DISTINCT cu.first_name || ' ' || cu.last_name AS full_name,
	o.order_id,
    CASE WHEN o.order_value > 100 THEN 'BIG'
    WHEN o.order_value > 25 THEN 'MEDIUM'
    WHEN o.order_value <= 25 THEN 'SMALL'
    ELSE '00-error'
    END AS order_size
FROM orders AS o
JOIN customers AS cu
ON cu.customer_id = o.customer_id
ORDER BY order_id;

--TASK 5--
-- Show all items from orders table which containt in their name 'ea' or start with 'Key'

SELECT item
FROM orders
WHERE item LIKE '%ea%' OR item LIKE 'Key%';
 
--TASK 6--
-- Please find out if some customer was referred by already existing customer
-- Return results in following format "Customer Last name Customer First name" "Last name First name of customer who recomended the new customer"
-- Sort/Order by customer last name (ascending)

SELECT
  c1.last_name || ' ' || c1.first_name AS "customer",
  c2.last_name || ' ' || c2.first_name AS "recommended_by"
FROM
  customers c1
JOIN
  customers c2 ON c1.referred_by_id = c2.customer_id
ORDER BY
  c1.last_name ASC;
