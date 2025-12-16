/* ==========================================================
   E-COMMERCE ANALYTICS PROJECT
   Author: Alam Maravilla Hernandez
   Description: End-to-end SQL analytics case study.
   Database: PostgreSQL
   ==========================================================

   PURPOSE OF THIS FILE
   --------------------
   This SQL file contains a complete set of analytical queries
   designed to answer real business questions for an e-commerce
   company. Each section includes:
   - A clear business problem statement
   - A fully written SQL solution
   - Clean formatting and consistent naming conventions

   ========================================================== */


/* ==========================================================
   SECTION 0: EXPLORATORY DATA ANALYSIS (EDA)
   BUSINESS GOAL:
   Understand the structure, fields, and key attributes of each
   table before performing analytical queries.
   ========================================================== */

-- Inspect product categories
SELECT * FROM category;

-- Inspect customer information
SELECT * FROM customers;

-- Inspect inventory and stock levels
SELECT * FROM inventory;

-- Inspect order line items
SELECT * FROM order_items;

-- Inspect order headers
SELECT * FROM orders;

-- Inspect payment transactions
SELECT * FROM payments;

-- Identify possible payment statuses
SELECT DISTINCT payment_status FROM payments;

-- Inspect product master data
SELECT * FROM products;

-- Inspect seller information
SELECT * FROM sellers;

-- Inspect shipping and delivery data
SELECT * FROM shippings;


/* ==========================================================
   SECTION 1: DATA PREPARATION
   BUSINESS PROBLEM:
   The order_items table does not contain a pre-calculated sales
   amount. Create and populate a column that represents the total
   revenue generated per line item.
   ========================================================== */

-- Add total_sale column if it does not exist
ALTER TABLE order_items
ADD COLUMN IF NOT EXISTS total_sale FLOAT;

-- Populate total_sale as quantity multiplied by unit price
UPDATE order_items
SET total_sale = quantity * price_per_unit;


/* ==========================================================
   SECTION 2: SALES & REVENUE ANALYSIS
   ========================================================== */

/* ----------------------------------------------------------
   PROBLEM 1:
   Identify the top 10 best-selling products based on total
   revenue and number of orders.
   ---------------------------------------------------------- */
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.total_sale) AS total_sales,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC
LIMIT 10;


/* ----------------------------------------------------------
   PROBLEM 2:
   Calculate total revenue by product category and determine
   each category's percentage contribution to overall revenue.
   ---------------------------------------------------------- */
SELECT
    p.category_id,
    c.category_name,
    SUM(oi.total_sale) AS total_sales,
    (SUM(oi.total_sale)
        / (SELECT SUM(total_sale) FROM order_items)) * 100
        AS revenue_percentage
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN category c ON c.category_id = p.category_id
GROUP BY p.category_id, c.category_name
ORDER BY revenue_percentage DESC;


/* ----------------------------------------------------------
   PROBLEM 3:
   Compute the average order value for customers who have placed
   more than five orders.
   ---------------------------------------------------------- */
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(oi.total_sale) / COUNT(o.order_id) AS avg_order_value,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, customer_name
HAVING COUNT(o.order_id) > 5
ORDER BY total_orders DESC, avg_order_value DESC;


/* ==========================================================
   SECTION 3: TIME SERIES ANALYSIS
   ========================================================== */

/* ----------------------------------------------------------
   PROBLEM 4:
   Analyze monthly sales trends for the last year and compare
   each month’s revenue with the previous month.
   ---------------------------------------------------------- */
SELECT
    month,
    year,
    total_sale AS current_month_sale,
    LAG(total_sale) OVER (ORDER BY year, month) AS previous_month_sale
FROM (
    SELECT
        EXTRACT(MONTH FROM o.order_date) AS month,
        EXTRACT(YEAR FROM o.order_date) AS year,
        ROUND(SUM(oi.total_sale::numeric), 2) AS total_sale
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 year'
    GROUP BY 1, 2
) monthly_sales;


/* ==========================================================
   SECTION 4: CUSTOMER ANALYTICS
   ========================================================== */

/* ----------------------------------------------------------
   PROBLEM 5:
   Identify customers who have never placed an order.
   ---------------------------------------------------------- */
SELECT *
FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id FROM orders
);


/* ----------------------------------------------------------
   PROBLEM 6:
   Calculate Customer Lifetime Value (CLTV) and rank customers
   based on total revenue generated.
   ---------------------------------------------------------- */
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(oi.total_sale) AS cltv,
    DENSE_RANK() OVER (ORDER BY SUM(oi.total_sale) DESC) AS customer_rank
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, customer_name;


/* ----------------------------------------------------------
   PROBLEM 7:
   Classify customers as New or Returning based on the number
   of returned orders.
   ---------------------------------------------------------- */
SELECT
    customer_name,
    total_orders,
    total_returns,
    CASE
        WHEN total_returns > 5 THEN 'Returning'
        ELSE 'New'
    END AS customer_type
FROM (
    SELECT
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(o.order_id) AS total_orders,
        SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) AS total_returns
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY customer_name
) customer_summary;


/* ----------------------------------------------------------
   PROBLEM 8:
   Identify the top five customers by number of orders within
   each state.
   ---------------------------------------------------------- */
SELECT *
FROM (
    SELECT
        c.state,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(o.order_id) AS total_orders,
        SUM(oi.total_sale) AS total_sales,
        DENSE_RANK() OVER (
            PARTITION BY c.state
            ORDER BY COUNT(o.order_id) DESC
        ) AS rank_within_state
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.state, customer_name
) ranked_customers
WHERE rank_within_state <= 5;


/* ==========================================================
   SECTION 5: PRODUCT & CATEGORY ANALYTICS
   ========================================================== */

/* ----------------------------------------------------------
   PROBLEM 9:
   Determine the best-selling product category by total sales
   for each state.
   ---------------------------------------------------------- */
SELECT state, category_name, total_sale
FROM (
    SELECT
        c.state,
        cat.category_name,
        SUM(oi.total_sale) AS total_sale,
        ROW_NUMBER() OVER (
            PARTITION BY c.state
            ORDER BY SUM(oi.total_sale) DESC
        ) AS rn
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN category cat ON cat.category_id = p.category_id
    GROUP BY c.state, cat.category_name
) ranked_categories
WHERE rn = 1;


/* ----------------------------------------------------------
   PROBLEM 10:
   Rank products by profit margin using cost of goods sold
   (COGS) and total sales.
   ---------------------------------------------------------- */
WITH profit_table AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.total_sale) AS total_sales,
        SUM(p.cogs * oi.quantity) AS total_cogs,
        SUM(oi.total_sale) - SUM(p.cogs * oi.quantity) AS profit
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_id,
    product_name,
    total_sales,
    total_cogs,
    profit,
    ROUND((profit / total_sales) * 100, 2) AS profit_margin,
    DENSE_RANK() OVER (ORDER BY profit / total_sales DESC) AS profit_rank
FROM profit_table;


/* ----------------------------------------------------------
   PROBLEM 11:
   Identify products with the highest return rates.
   ---------------------------------------------------------- */
SELECT
    p.product_id,
    p.product_name,
    COUNT(*) AS total_units_sold,
    SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) AS total_returns,
    (SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END)::numeric
        / COUNT(*)::numeric) * 100 AS return_rate
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
GROUP BY p.product_id, p.product_name
ORDER BY total_returns DESC
LIMIT 10;


/* ==========================================================
   SECTION 6: SELLER & OPERATIONS ANALYTICS
   ========================================================== */

/* ----------------------------------------------------------
   PROBLEM 12:
   Evaluate the success rate of the top five sellers based on
   completed orders.
   ---------------------------------------------------------- */
WITH top_sellers AS (
    SELECT
        s.seller_id,
        s.seller_name,
        SUM(oi.total_sale) AS total_sale
    FROM orders o
    JOIN sellers s ON o.seller_id = s.seller_id
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY s.seller_id, s.seller_name
    ORDER BY total_sale DESC
    LIMIT 5
), seller_performance AS (
    SELECT
        o.seller_id,
        ts.seller_name,
        o.order_status,
        COUNT(*) AS total_orders
    FROM orders o
    JOIN top_sellers ts ON ts.seller_id = o.seller_id
    WHERE o.order_status NOT IN ('Inprogress', 'Returned')
    GROUP BY o.seller_id, ts.seller_name, o.order_status
)
SELECT
    seller_id,
    seller_name,
    SUM(CASE WHEN order_status = 'Completed' THEN total_orders ELSE 0 END)::numeric
        / SUM(total_orders)::numeric * 100 AS success_rate
FROM seller_performance
GROUP BY seller_id, seller_name;


/* ----------------------------------------------------------
   PROBLEM 13:
   Identify sellers who have not made any sales in the last
   six months and retrieve their most recent sale.
   ---------------------------------------------------------- */
WITH inactive_sellers AS (
    SELECT seller_id
    FROM sellers
    WHERE seller_id NOT IN (
        SELECT seller_id
        FROM orders
        WHERE order_date >= CURRENT_DATE - INTERVAL '6 months'
    )
)
SELECT
    o.seller_id,
    MAX(o.order_date) AS last_sale_date,
    MAX(oi.total_sale) AS last_sale_amount
FROM orders o
JOIN inactive_sellers i ON o.seller_id = i.seller_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.seller_id;


/* ==========================================================
   SECTION 7: LOGISTICS & PAYMENTS
   ========================================================== */

/* ----------------------------------------------------------
   PROBLEM 14:
   Identify orders where shipping was delayed by more than
   three days.
   ---------------------------------------------------------- */
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_id,
    s.shipping_providers,
    s.shipping_date - o.order_date AS delay_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN shippings s ON o.order_id = s.order_id
WHERE s.shipping_date > o.order_date + INTERVAL '3 days';


/* ----------------------------------------------------------
   PROBLEM 15:
   Analyze revenue, order volume, and average delivery time
   by shipping provider.
   ---------------------------------------------------------- */
SELECT
    s.shipping_providers,
    SUM(oi.total_sale) AS total_revenue,
    COUNT(o.order_id) AS total_orders,
    AVG(s.shipping_date - o.order_date) AS avg_delivery_time
FROM orders o
JOIN shippings s ON o.order_id = s.order_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY s.shipping_providers;


/* ----------------------------------------------------------
   PROBLEM 16:
   Calculate the distribution and success rate of payment
   transactions by payment status.
   ---------------------------------------------------------- */
SELECT
    payment_status,
    COUNT(*) AS total_count,
    COUNT(*)::numeric
        / (SELECT COUNT(*) FROM payments)::numeric * 100
        AS percentage
FROM payments
GROUP BY payment_status;


/* ==========================================================
   SECTION 8: YEAR-OVER-YEAR ANALYSIS
   ========================================================== */

/* ----------------------------------------------------------
   PROBLEM 17:
   Identify the top 10 products with the largest revenue decline
   between 2022 and 2023.
   ---------------------------------------------------------- */
WITH current_year AS (
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,
        SUM(oi.total_sale) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON p.product_id = oi.product_id
    JOIN category c ON c.category_id = p.category_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2023
    GROUP BY p.product_id, p.product_name, c.category_name
), last_year AS (
    SELECT
        p.product_id,
        SUM(oi.total_sale) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2022
    GROUP BY p.product_id
)
SELECT
    cy.product_id,
    cy.product_name,
    cy.category_name,
    cy.revenue AS revenue_2023,
    ly.revenue AS revenue_2022,
    ROUND(((cy.revenue - ly.revenue) / ly.revenue) * 100, 2)
        AS revenue_decline_pct
FROM current_year cy
JOIN last_year ly ON cy.product_id = ly.product_id
WHERE cy.revenue < ly.revenue
ORDER BY revenue_decline_pct ASC
LIMIT 10;


/* ==========================================================
   SECTION 9: AUTOMATION
   ========================================================== */

/* ----------------------------------------------------------
   PROBLEM 18:
   Create a stored procedure that inserts a new sale, validates
   inventory availability, updates stock levels, and records
   the transaction.
   ---------------------------------------------------------- */
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
    WHERE product_id = p_product_id
      AND stock >= p_quantity;

    IF v_count > 0 THEN
        INSERT INTO orders (order_id, order_date, customer_id, seller_id)
        VALUES (p_order_id, CURRENT_DATE, p_customer_id, p_seller_id);

        INSERT INTO order_items (
            order_item_id,
            order_id,
            product_id,
            quantity,
            price_per_unit,
            total_sale
        )
        VALUES (
            p_order_item_id,
            p_order_id,
            p_product_id,
            p_quantity,
            v_price,
            v_price * p_quantity
        );

        UPDATE inventory
        SET stock = stock - p_quantity
        WHERE product_id = p_product_id;

        RAISE NOTICE 'Product % sold successfully and inventory updated.', v_product;
    ELSE
        RAISE NOTICE 'Insufficient inventory for product %.', v_product;
    END IF;
END;
$$;
