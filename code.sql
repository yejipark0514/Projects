--Table descriptions--

SELECT 'Products' AS table_name,
		9 AS number_of_attributes,
		COUNT(*) AS number_of_rows
	FROM products
	
UNION ALL

SELECT 'Customers' AS table_name,
		13 AS number_of_attributes,
		COUNT(*) AS number_of_rows
	FROM customers

UNION ALL

SELECT 'ProductLines' AS table_name,
		4 AS number_of_attributes,
		COUNT(*) AS number_of_rows
	FROM productlines

UNION ALL

SELECT 'Orders' AS table_name,
		7 AS number_of_attributes,
		COUNT(*) AS number_of_rows
	FROM orders
	
UNION ALL

SELECT 'OrderDetails' AS table_name,
		5 AS number_of_attributes,
		COUNT(*) AS number_of_rows
	FROM orderdetails

UNION ALL 

SELECT 'Payments' AS table_name,
		4 AS number_of_attributes,
		COUNT(*) AS number_of_rows
	FROM payments
	
UNION ALL

SELECT 'Employees' AS table_name,
		8 AS number_of_attributes,
		COUNT(*) AS number_of_rows
	FROM employees
	
UNION ALL

SELECT 'Offices' AS table_name,
		9 AS number_of_attributes,
		COUNT(*) AS number_of_rows
	FROM offices;
	
 --Product Performance--
SELECT productCode,
		SUM(quantityOrdered * priceEach) AS product_perf
	FROM orderdetails od
	GROUP BY productCode
	ORDER BY product_perf DESC
	LIMIT 10;

--Priority Products for restocking--
WITH

low_stock_table AS (
SELECT productCode,
		ROUND(SUM(quantityOrdered) * 1.0/(SELECT quantityInStock
											FROM products p
											WHERE od.productCode = p.productCode), 2) AS low_stock
	FROM orderdetails od
	GROUP BY productCode
	ORDER BY low_stock
	LIMIT 10
)

SELECT productCode,
		SUM(quantityOrdered * priceEach) AS product_perf
	FROM orderdetails od
	WHERE productCode IN (SELECT productCode
							FROM low_stock_table)
	GROUP BY productCode
	ORDER BY product_perf DESC
	LIMIT 10;
	
/* Screen 5 */
-- revenue by customer
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber;	
	
-- Top 5 VIP customers
WITH 

money_in_by_customer_table AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
)

SELECT contactLastName, contactFirstName, city, country, mc.revenue
  FROM customers c
  JOIN money_in_by_customer_table mc
    ON mc.customerNumber = c.customerNumber
 ORDER BY mc.revenue DESC
 LIMIT 5;
 
 -- Top 5 less engaging customers
WITH 

money_in_by_customer_table AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
)

SELECT contactLastName, contactFirstName, city, country, mc.revenue
  FROM customers c
  JOIN money_in_by_customer_table mc
    ON mc.customerNumber = c.customerNumber
 ORDER BY mc.revenue
 LIMIT 5;											

-- Customer LTV
WITH 

money_in_by_customer_table AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
)

SELECT AVG(mc.revenue) AS ltv
  FROM money_in_by_customer_table mc;
