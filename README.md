# -SQL-for-Data-Analysis
 📌 Objective

The goal of this task is to use SQL queries to extract and analyze data from a relational database. This demonstrates proficiency with basic to advanced SQL features, including filtering, sorting, grouping, joins, subqueries, views, and indexing.

🗄️ Dataset Used

We created a sample E-commerce Database (ecommerce_db) using MySQL/phpMyAdmin.

Main tables:

customers → Customer details (ID, name, email, phone, created_at)

categories → Product categories

products → Product information (ID, name, price, category)

orders → Order-level details (ID, customer_id, order_date, status)

order_items → Line items per order (product, quantity, unit_price)

payments → Payment details (order_id, method, amount, status)

shipments → Shipping and delivery details

inventory → Stock management

👉 The schema and initial data load can be found in schema_and_data.sql

schema_and_data

.

⚙️ Queries Implemented

All queries are documented in task3_queries.sql

task3_queries

. Key categories include:

Basic Exploration

SELECT * FROM customers LIMIT 10;

Filtering & Sorting

Customers with last name 'Patel', sorted alphabetically.

Aggregation

Total revenue per customer using SUM() and GROUP BY.

Joins

Combined data from orders, customers, order_items, and products.

Subqueries

Customers who spent more than 50,000 total.

Views

vw_order_totals → total per order

vw_high_value_customers → customers with spend > 50,000

vw_product_sales → units sold and revenue per product

Indexes

Indexes created to optimize joins and lookups.

Analytical Queries

ARPU (Average Revenue Per User)

Top 5 products by units sold

Revenue breakdown by payment method

Monthly revenue trends

NULL handling demo with COALESCE

📸 Screenshots

Screenshots of executed queries and results are included in the /screenshots folder:

customer_select.png → First 10 customers

join_query.png → Orders joined with customers & products

arpu.png → Average Revenue Per User (ARPU)

📊 Insights Gained

Identified high-value customers with spending above 50,000.

Determined ARPU ≈ 70,598.00 (from sample data).

Ranked top-selling products by sales volume and revenue.

Observed successful payments split across methods (card, UPI).

Demonstrated indexing strategies to speed up query performance.

🚀 How to Run

Import schema_and_data.sql into MySQL/phpMyAdmin.

Run queries from task3_queries.sql.

Validate results (compare with screenshots).
