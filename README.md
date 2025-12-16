# amazon_project
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

## ⭐ Final Notes

This project emphasizes **clarity, performance, and business relevance**. Queries are written to be **readable, scalable, and production-aware**, reflecting real-world analytical workflows.

Feel free to ⭐ the repo, fork it, or extend the analysis!
