-- ============================================================
-- Part 3.2 — Analytical Queries
-- ============================================================


-- Q1: Total sales revenue by product category for each month
-- ─────────────────────────────────────────────────────────────

SELECT
    d.year,
    d.month_num,
    d.month_name,
    p.category,
    COUNT(f.sale_id)           AS transaction_count,
    SUM(f.units_sold)          AS total_units,
    SUM(f.total_revenue)       AS total_revenue,
    ROUND(AVG(f.total_revenue), 2) AS avg_transaction_value
FROM fact_sales    f
JOIN dim_date      d ON f.date_key    = d.date_key
JOIN dim_product   p ON f.product_key = p.product_key
GROUP BY
    d.year,
    d.month_num,
    d.month_name,
    p.category
ORDER BY
    d.year       ASC,
    d.month_num  ASC,
    total_revenue DESC;


-- Q2: Top 2 performing stores by total revenue
-- ─────────────────────────────────────────────────────────────

SELECT
    s.store_id,
    s.store_name,
    s.city,
    s.region,
    COUNT(f.sale_id)      AS transaction_count,
    SUM(f.units_sold)     AS total_units_sold,
    SUM(f.total_revenue)  AS total_revenue,
    ROUND(SUM(f.total_revenue) / COUNT(f.sale_id), 2) AS avg_revenue_per_txn
FROM fact_sales f
JOIN dim_store  s ON f.store_key = s.store_key
GROUP BY
    s.store_key,
    s.store_id,
    s.store_name,
    s.city,
    s.region
ORDER BY total_revenue DESC
LIMIT 2;


-- Q3: Month-over-month sales trend across all stores
-- ─────────────────────────────────────────────────────────────

WITH monthly_revenue AS (
    SELECT
        d.year,
        d.month_num,
        d.month_name,
        SUM(f.total_revenue)  AS monthly_revenue,
        SUM(f.units_sold)     AS monthly_units,
        COUNT(f.sale_id)      AS transaction_count
    FROM fact_sales  f
    JOIN dim_date    d ON f.date_key = d.date_key
    GROUP BY
        d.year,
        d.month_num,
        d.month_name
)
SELECT
    curr.year,
    curr.month_num,
    curr.month_name,
    curr.transaction_count,
    curr.monthly_units,
    curr.monthly_revenue,
    prev.monthly_revenue                                           AS prev_month_revenue,
    ROUND(curr.monthly_revenue - COALESCE(prev.monthly_revenue, 0), 2)
                                                                   AS mom_revenue_change,
    CASE
        WHEN prev.monthly_revenue IS NULL     THEN NULL   -- first month: no prior period
        WHEN prev.monthly_revenue = 0         THEN NULL   -- guard against divide-by-zero
        ELSE ROUND(
               (curr.monthly_revenue - prev.monthly_revenue)
               / prev.monthly_revenue * 100, 2)
    END                                                            AS mom_growth_pct
FROM monthly_revenue curr
LEFT JOIN monthly_revenue prev
    -- join to the immediately preceding calendar month (handles year-boundary rollover)
    ON  prev.year      = CASE WHEN curr.month_num = 1 THEN curr.year - 1 ELSE curr.year END
    AND prev.month_num = CASE WHEN curr.month_num = 1 THEN 12           ELSE curr.month_num - 1 END
ORDER BY
    curr.year      ASC,
    curr.month_num ASC;
