# 🛒 E-commerce SQL Analytics Project

## 📌 Overview

This project is a **comprehensive SQL-based analytics case study** built on an e-commerce database. It focuses on **exploratory data analysis (EDA)**, **business-driven analytical queries**, and **advanced SQL techniques** such as **CTEs, window functions, ranking, aggregations, and stored procedures**.

The goal is to simulate **real-world data analyst / analytics engineer tasks**, answering meaningful business questions around **sales, customers, products, sellers, inventory, payments, and logistics**.

---

## 🎯 Objectives

* Perform **Exploratory Data Analysis (EDA)** to understand the data model
* Solve **realistic business problems** using SQL
* Apply **advanced SQL concepts**:

  * Window functions (RANK, DENSE_RANK, LAG)
  * CTEs
  * Aggregations & conditional logic
  * Time-based analysis
* Build **production-like SQL logic**, including a **stored procedure**
* Generate insights useful for **decision-making in e-commerce**

---

## 🧱 Database Schema

The analysis is based on the following core tables:

* `customers`
* `orders`
* `order_items`
* `products`
* `category`
* `sellers`
* `inventory`
* `payments`
* `shippings`

Each table represents a typical e-commerce domain entity such as customers, transactions, logistics, and stock management.

---

## 🔍 Exploratory Data Analysis (EDA)

Initial exploration to understand structure, relationships, and available fields:

```sql
SELECT * FROM category;
SELECT * FROM customers;
SELECT * FROM inventory;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM payments;
SELECT DISTINCT(payment_status) FROM payments;
SELECT * FROM products;
SELECT * FROM sellers;
SELECT * FROM shippings;
```

---

## 📊 Business Questions & Solutions

### 1️⃣ Top Selling Products

**Question:** Identify the top 10 products by total sales value.

**Key Metrics:**

* Product name
* Total quantity sold
* Total sales value

**Techniques Used:** JOINs, aggregation, calculated columns

---

### 2️⃣ Revenue by Category

**Question:** Calculate total revenue per category and its percentage contribution.

**Techniques Used:**

* Subqueries
* Window functions
* Percentage calculations

---

### 3️⃣ Average Order Value (AOV)

**Question:** Compute average order value per customer.

**Constraint:** Only include customers with more than 5 orders.

**Techniques Used:**

* CTEs
* Aggregations
* HAVING clause

---

### 4️⃣ Monthly Sales Trend

**Question:** Analyze monthly sales trends.

**Challenge:**

* Show current month vs previous month sales

**Techniques Used:**

* Date extraction
* LAG window function

---

### 5️⃣ Customers With No Purchases

**Question:** Identify customers who registered but never placed an order.

**Techniques Used:** Subqueries, NOT IN

---

### 6️⃣ Best & Least Selling Categories by State

**Question:** Identify best and worst selling product categories per state.

**Techniques Used:**

* Window functions (ROW_NUMBER, RANK)
* Partitioning by state

---

### 7️⃣ Customer Lifetime Value (CLTV)

**Question:** Calculate total lifetime value per customer and rank them.

**Techniques Used:**

* Aggregations
* DENSE_RANK

---

### 8️⃣ Inventory Stock Alerts

**Question:** Identify products with critically low stock (< 10 units).

**Additional Info:**

* Last restock date
* Warehouse ID

---

### 9️⃣ Shipping Delays

**Question:** Identify orders shipped more than 3 days after order date.

**Includes:**

* Customer details
* Delivery provider
* Shipping delay duration

---

### 🔟 Payment Success Rate

**Question:** Calculate payment success rates and breakdown by payment status.

**Techniques Used:**

* Aggregations
* Percentage calculations

---

### 1️⃣1️⃣ Top Performing Sellers

**Question:** Identify top 5 sellers by revenue.

**Challenge:**

* Include success vs failure rates

**Techniques Used:**

* Multi-CTE design
* Conditional aggregation

---

### 1️⃣2️⃣ Product Profit Margin

**Question:** Calculate and rank products by profit margin.

**Metrics:**

* Revenue
* COGS
* Profit
* Profit margin %

---

### 1️⃣3️⃣ Most Returned Products

**Question:** Identify products with the highest return rate.

**Metric:** Returned units as a % of total sold units

---

### 1️⃣5️⃣ Inactive Sellers

**Question:** Identify sellers with no sales in the last 6 months.

**Includes:**

* Last sale date
* Last sale amount

---

### 1️⃣6️⃣ Customer Classification

**Question:** Classify customers as **Returning** or **New** based on returns.

**Rule:**

* More than 5 returns → Returning Customer

---

### 1️⃣7️⃣ Top Customers per State

**Question:** Top 5 customers by number of orders in each state.

**Includes:**

* Total orders
* Total sales

---

### 1️⃣8️⃣ Revenue by Shipping Provider

**Question:** Calculate revenue handled by each shipping provider.

**Includes:**

* Total revenue
* Number of orders
* Average delivery time

---

### 1️⃣9️⃣ Products With Declining Revenue (YoY)

**Question:** Identify products with declining revenue from 2022 → 2023.

**Metric:** Revenue decrease ratio (%)

---

## ⚙️ Stored Procedure: Inventory Auto-Update

### 🎯 Goal

Automatically **reduce inventory stock** when a sale is made.

### 🔧 Logic Implemented

* Validate product availability
* Insert into `orders` and `order_items`
* Update inventory stock accordingly
* Handle insufficient stock gracefully

```sql
CREATE OR REPLACE PROCEDURE add_sales(...)
```

This simulates **real transactional logic** used in production systems.

---

## 🧠 Key SQL Skills Demonstrated

* Advanced JOINs
* Window Functions
* CTEs
* Date & time analysis
* Conditional aggregation
* Stored procedures (PL/pgSQL)
* Business-driven analytics

---

## 🚀 How to Use

1. Load the database schema and data
2. Execute queries in order (EDA → business logic)
3. Modify thresholds, dates, or constraints to explore new insights

---

## 📈 Use Cases

* Portfolio project for **Data Analyst / Analytics Engineer roles**
* SQL interview preparation
* Business intelligence simulations
* E-commerce analytics practice

---

## 👤 Author

**Alam Maravilla Hernandez**
Industrial Engineer | Data & SQL Enthusiast

---

## 🧾 SQL Queries

Below are the **exact SQL queries** used to solve each business problem. Queries are grouped by topic and ordered logically from EDA to advanced analytics and automation.

---

### 🔍 Exploratory Data Analysis (EDA)

```sql
SELECT * FROM category;
SELECT * FROM customers;
SELECT * FROM inventory;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM payments;
SELECT DISTINCT(payment_status) FROM payments;
SELECT * FROM products;
SELECT * FROM sellers;
SELECT * FROM shippings;
```

---

### 1️⃣ Top Selling Products

```sql
ALTER TABLE order_items
ADD COLUMN total_sale FLOAT;

UPDATE order_items
SET total_sale = quantity * price_per_unit;

SELECT p.product_id,
       p.product_name,
       SUM(oi.total_sale) AS total_sale,
       COUNT(o.order_id) AS total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY 1,2
ORDER BY total_sale DESC
LIMIT 10;
```

---

### 2️⃣ Revenue by Category

```sql
SELECT
  p.category_id,
  c.category_name,
  SUM(oi.total_sale) AS total_sale,
  (SUM(oi.total_sale) / (SELECT SUM(total_sale) FROM order_items)) * 100 AS percentage
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category c ON c.category_id = p.category_id
GROUP BY 1,2
ORDER BY 4 DESC;
```

---

### 3️⃣ Average Order Value (Customers with >5 Orders)

```sql
SELECT
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS full_name,
  SUM(oi.total_sale)/COUNT(o.order_id) AS avg_value,
  COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY 1,2
HAVING COUNT(o.order_id) > 5
ORDER BY 4 DESC, 3 DESC;
```

---

### 4️⃣ Monthly Sales Trend (Current vs Previous Month)

```sql
SELECT month,
       year,
       total_sale AS current_month_sale,
       LAG(total_sale) OVER (ORDER BY year, month) AS last_month_sale
FROM (
  SELECT EXTRACT(MONTH FROM o.order_date) AS month,
         EXTRACT(YEAR FROM o.order_date) AS year,
         ROUND(SUM(oi.total_sale::numeric), 2) AS total_sale
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 year'
  GROUP BY 1,2
) t;
```

---

### 5️⃣ Customers With No Purchases

```sql
SELECT *
FROM customers
WHERE customer_id NOT IN (
  SELECT DISTINCT customer_id FROM orders
);
```

---

### 6️⃣ Best Selling Category by State

```sql
SELECT state,
       product_category,
       total_sale
FROM (
  SELECT cs.state,
         c.category_name AS product_category,
         SUM(oi.total_sale) AS total_sale,
         ROW_NUMBER() OVER (PARTITION BY cs.state ORDER BY SUM(oi.total_sale) DESC) rn
  FROM order_items oi
  JOIN products p ON oi.product_id = p.product_id
  JOIN category c ON c.category_id = p.category_id
  JOIN orders o ON oi.order_id = o.order_id
  JOIN customers cs ON cs.customer_id = o.customer_id
  GROUP BY cs.state, c.category_id
) t
WHERE rn = 1;
```

---

### 7️⃣ Customer Lifetime Value (CLTV)

```sql
SELECT
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS full_name,
  SUM(oi.total_sale) AS cltv,
  DENSE_RANK() OVER (ORDER BY SUM(oi.total_sale) DESC) AS ranking
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY 1,2;
```

---

### 8️⃣ Inventory Stock Alerts

```sql
SELECT inv.inventory_id,
       p.product_name,
       inv.stock AS current_stock,
       inv.last_stock_date,
       inv.warehouse_id
FROM inventory inv
JOIN products p ON inv.product_id = p.product_id
WHERE inv.stock < 10;
```

---

### 9️⃣ Shipping Delays (>3 Days)

```sql
SELECT c.*, o.*, s.shipping_providers,
       s.shipping_date - o.order_date AS days_delayed
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN shippings s ON o.order_id = s.order_id
WHERE s.shipping_date > o.order_date + INTERVAL '3 day';
```

---

### 🔟 Payment Success Rate

```sql
SELECT payment_status,
       COUNT(*) AS count_status,
       COUNT(*)::numeric / (SELECT COUNT(*) FROM payments)::numeric * 100 AS percentage
FROM payments
GROUP BY payment_status;
```

---

### 1️⃣1️⃣ Top Performing Sellers

```sql
WITH top_sellers AS (
  SELECT s.seller_id,
         s.seller_name,
         SUM(oi.total_sale) AS total_sale
  FROM orders o
  JOIN sellers s ON o.seller_id = s.seller_id
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY 1,2
  ORDER BY 3 DESC
  LIMIT 5
), sellers_report AS (
  SELECT o.seller_id,
         ts.seller_name,
         o.order_status,
         COUNT(*) AS total_orders
  FROM orders o
  JOIN top_sellers ts ON ts.seller_id = o.seller_id
  WHERE o.order_status NOT IN ('Inprogress', 'Returned')
  GROUP BY 1,2,3
)
SELECT seller_id,
       seller_name,
       SUM(CASE WHEN order_status = 'Completed' THEN total_orders ELSE 0 END)::numeric
       / SUM(total_orders)::numeric * 100 AS success_rate
FROM sellers_report
GROUP BY 1,2;
```

---

### ⚙️ Stored Procedure – Inventory Auto Update

```sql
CREATE OR REPLACE PROCEDURE add_sales(
  p_order_id INT,
  p_customer_id INT,
  p_seller_id INT,
  p_order_item_id INT,
  p_product_id INT,
  p_quantity INT
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_count INT;
  v_price FLOAT;
  v_product VARCHAR(50);
BEGIN
  SELECT price, product_name
  INTO v_price, v_product
  FROM products
  WHERE product_id = p_product_id;

  SELECT COUNT(*)
  INTO v_count
  FROM inventory
  WHERE product_id = p_product_id AND stock >= p_quantity;

  IF v_count > 0 THEN
    INSERT INTO orders(order_id, order_date, customer_id, seller_id)
    VALUES (p_order_id, CURRENT_DATE, p_customer_id, p_seller_id);

    INSERT INTO order_items(order_item_id, order_id, product_id, quantity, price_per_unit, total_sale)
    VALUES (p_order_item_id, p_order_id, p_product_id, p_quantity, v_price, v_price * p_quantity);

    UPDATE inventory
    SET stock = stock - p_quantity
    WHERE product_id = p_product_id;

    RAISE NOTICE 'Product % sold and inventory updated', v_product;
  ELSE
    RAISE NOTICE 'Product % not available in required quantity', v_product;
  END IF;
END;
$$;
```

---

## ⭐ Final Notes

This project emphasizes **clarity, performance, and business relevance**. Queries are written to be **readable, scalable, and production-aware**, reflecting real-world analytical workflows.

