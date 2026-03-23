-- ============================================================
-- Part 5.1 — Cross-Format Queries using DuckDB
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- Q1: List all customers along with the total number of orders they have placed
SELECT
    c.customer_id,
    c.name                          AS customer_name,
    c.city,
    COUNT(o.order_id)               AS total_orders
FROM read_csv_auto('customers.csv')                         AS c
LEFT JOIN read_json_auto('orders.json')                     AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.name,
    c.city
ORDER BY total_orders DESC, c.name ASC;


-- ─────────────────────────────────────────────────────────────
-- Q2: Find the top 3 customers by total order value

SELECT
    c.customer_id,
    c.name                              AS customer_name,
    c.city,
    COUNT(o.order_id)                   AS total_orders,
    COALESCE(SUM(o.total_amount), 0)    AS total_order_value
FROM read_csv_auto('customers.csv')                         AS c
LEFT JOIN read_json_auto('orders.json')                     AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.name,
    c.city
ORDER BY total_order_value DESC
LIMIT 3;


-- ─────────────────────────────────────────────────────────────
-- Q3: List all products purchased by customers from Bangalore

SELECT DISTINCT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price
FROM read_csv_auto('customers.csv')                         AS c
JOIN read_json_auto('orders.json')                          AS o
    ON  c.customer_id = o.customer_id
JOIN read_parquet('products.parquet')                       AS p
    ON  o.order_id    = p.order_id
WHERE c.city = 'Bangalore'
ORDER BY p.category, p.product_name;


-- ─────────────────────────────────────────────────────────────
-- Q4: Join all three files to show: customer name, order date, product name, and quantity

SELECT
    c.name                              AS customer_name,
    c.city,
    CAST(o.order_date AS DATE)          AS order_date,
    o.order_id,
    o.status                            AS order_status,
    p.product_name,
    p.category,
    p.quantity,
    p.unit_price,
    p.total_price
FROM read_csv_auto('customers.csv')                         AS c
JOIN read_json_auto('orders.json')                          AS o
    ON  c.customer_id = o.customer_id
JOIN read_parquet('products.parquet')                       AS p
    ON  o.order_id    = p.order_id
ORDER BY
    c.name      ASC,
    o.order_date ASC,
    p.product_name ASC;
