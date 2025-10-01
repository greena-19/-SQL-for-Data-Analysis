-- See tables
SHOW TABLES;

--  data peek
SELECT * FROM customers LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM order_items LIMIT 10;

-- Basic counts
SELECT COUNT(*) AS customers FROM customers;
SELECT COUNT(*) AS products  FROM products;
SELECT COUNT(*) AS orders    FROM orders;
SELECT COUNT(*) AS items     FROM order_items;

-- 1) Filtering & Sorting
-- Customers whose last name is 'Patel', sorted by first name
SELECT customer_id, first_name, last_name, email
FROM customers
WHERE last_name = 'Patel'
ORDER BY first_name ASC;

-- 2) Aggregation (revenue per customer)
-- Your orders table doesn’t store amount directly, so compute it from order_items (quantity * unit_price).
-- Revenue per customer (JOIN + GROUP BY)
SELECT  o.customer_id,
        CONCAT(c.first_name,' ',c.last_name) AS customer_name,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM orders o
JOIN customers c  ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.customer_id, customer_name
ORDER BY total_revenue DESC;

-- 3) Classic JOIN result (order lines with product names)
SELECT  o.order_id,
        CONCAT(c.first_name,' ',c.last_name) AS customer_name,
        p.name AS product_name,
        oi.quantity,
        oi.unit_price,
        (oi.quantity * oi.unit_price) AS line_amount
FROM orders o
JOIN customers c   ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
ORDER BY o.order_id, product_name;

-- 4) Subquery examples
-- Customers whose total spend > 50,000 (IN + GROUP BY in subquery)
SELECT first_name, last_name
FROM customers
WHERE customer_id IN (
  SELECT o.customer_id
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY o.customer_id
  HAVING SUM(oi.quantity * oi.unit_price) > 50000
);

-- 5) Views (create once, then SELECT for screenshots)
-- Drop-if-exists so you can re-run safely
DROP VIEW IF EXISTS vw_order_totals;
DROP VIEW IF EXISTS vw_high_value_customers;
DROP VIEW IF EXISTS vw_product_sales;

-- View: order totals (amount per order)
CREATE VIEW vw_order_totals AS
SELECT  o.order_id,
        o.customer_id,
        o.order_date,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS order_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.customer_id, o.order_date;

-- View: high value customers (> 50,000)
CREATE VIEW vw_high_value_customers AS
SELECT  customer_id,
        ROUND(SUM(order_total), 2) AS total_spent
FROM vw_order_totals
GROUP BY customer_id
HAVING SUM(order_total) > 50000;

-- View: product sales (units & revenue)
CREATE VIEW vw_product_sales AS
SELECT  p.product_id,
        p.name AS product_name,
        SUM(oi.quantity) AS units_sold,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name;


SELECT * FROM vw_order_totals;
SELECT * FROM vw_high_value_customers;
SELECT * FROM vw_product_sales ORDER BY units_sold DESC;

-- 6) Indexing (you already added some — here’s one more useful one)
-- Speeds up lookups by email
CREATE INDEX idx_customers_email ON customers(email);

-- 7) Analytical queries for your report/screenshots
-- a) ARPU (Average Revenue Per User)
-- Using the view to keep it simple
SELECT ROUND(AVG(customer_total), 2) AS avg_revenue_per_user
FROM (
  SELECT customer_id, SUM(order_total) AS customer_total
  FROM vw_order_totals
  GROUP BY customer_id
) t;

-- b) Top 5 products by units sold
SELECT product_name, units_sold
FROM vw_product_sales
ORDER BY units_sold DESC, product_name
LIMIT 5;

-- c) Revenue by order (nice compact view of amounts)
SELECT o.order_id,
       CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       v.order_total
FROM vw_order_totals v
JOIN customers c ON c.customer_id = v.customer_id
JOIN orders o    ON o.order_id = v.order_id
ORDER BY v.order_total DESC;

-- d) Revenue by payment method
SELECT  method,
        ROUND(SUM(amount), 2) AS total_paid,
        COUNT(*) AS payments_count
FROM payments
WHERE status = 'successful'
GROUP BY method
ORDER BY total_paid DESC;

-- e) Monthly revenue (works even with small seed; good for real data)
SELECT  DATE_FORMAT(order_date, '%Y-%m') AS yyyymm,
        ROUND(SUM(order_total), 2) AS monthly_revenue
FROM vw_order_totals
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY yyyymm;

-- 8) NULL handling demo 
-- Sample pattern: turn NULLs into 0 when summing (COALESCE)
SELECT  o.order_id,
        COALESCE(ROUND(SUM(oi.quantity * oi.unit_price), 2), 0) AS order_total_safe
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id;
