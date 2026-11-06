-- E-commerce analysis queries. SQLite syntax, portable to PostgreSQL or MySQL with minor date-function changes
-- Tables: customers, products, orders, order_items   (load with sql/load_db.py)

-- 1. Headline KPIs (delivered orders only)
-- 1. Headline KPIs (delivered orders only)

SELECT
    ROUND(SUM(oi.quantity * p.unit_price *
        (1 - oi.discount_pct / 100.0)), 0) AS revenue,

    ROUND(SUM(oi.quantity *
        (p.unit_price * (1 - oi.discount_pct / 100.0) - p.unit_cost)), 0) AS profit,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        SUM(oi.quantity * p.unit_price *
            (1 - oi.discount_pct / 100.0))
        / COUNT(DISTINCT o.order_id), 0
    ) AS avg_order_value

FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id

WHERE o.status = 'Delivered';

-- 2. Monthly revenue with month-over-month growth (window function)

WITH monthly AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        SUM(
            oi.quantity * p.unit_price *
            (1 - oi.discount_pct / 100.0)
        ) AS revenue

    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id

    WHERE o.status = 'Delivered'

    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)

SELECT
    month,
    ROUND(revenue, 0) AS revenue,

    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
        1
    ) AS mom_growth_pct

FROM monthly
ORDER BY month;

-- 3. Category revenue, profit and margin
-- 3. Category revenue, profit and margin

SELECT
    p.category,

    ROUND(SUM(
        oi.quantity * p.unit_price *
        (1 - oi.discount_pct / 100.0)
    ), 0) AS revenue,

    ROUND(SUM(
        oi.quantity *
        (p.unit_price * (1 - oi.discount_pct / 100.0) - p.unit_cost)
    ), 0) AS profit,

    ROUND(
        100.0 * SUM(
            oi.quantity *
            (p.unit_price * (1 - oi.discount_pct / 100.0) - p.unit_cost)
        )
        / NULLIF(SUM(
            oi.quantity * p.unit_price *
            (1 - oi.discount_pct / 100.0)
        ), 0),
        1
    ) AS margin_pct

FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id

WHERE o.status = 'Delivered'

GROUP BY p.category
ORDER BY revenue DESC;

-- 4. Top 3 products per category by revenue (RANK window function)
-- 4. Top 3 products per category by revenue

WITH prod_rev AS (
    SELECT
        p.category,
        p.product_name,

        SUM(
            oi.quantity * p.unit_price *
            (1 - oi.discount_pct / 100.0)
        ) AS revenue

    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id

    WHERE o.status = 'Delivered'

    GROUP BY p.category, p.product_name
),

ranked AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS rnk

    FROM prod_rev
)

SELECT
    category,
    product_name,
    ROUND(revenue, 0) AS revenue,
    rnk

FROM ranked
WHERE rnk <= 3

ORDER BY category, rnk;

-- 5. Customer lifetime value & top 10 customers
-- 5. Customer lifetime value and top 10 customers

SELECT
    c.customer_id,
    c.state,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(SUM(
        oi.quantity * p.unit_price *
        (1 - oi.discount_pct / 100.0)
    ), 0) AS lifetime_value

FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id

WHERE o.status = 'Delivered'

GROUP BY c.customer_id, c.state

ORDER BY lifetime_value DESC

LIMIT 10;
-- 6. Pareto: share of revenue from top 20% of customers
-- 6. Revenue contribution by customer quintile

WITH cust AS (
    SELECT
        o.customer_id,

        SUM(
            oi.quantity * p.unit_price *
            (1 - oi.discount_pct / 100.0)
        ) AS rev

    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id

    WHERE o.status = 'Delivered'

    GROUP BY o.customer_id
),

r AS (
    SELECT
        customer_id,
        rev,

        NTILE(5) OVER (
            ORDER BY rev DESC
        ) AS quintile

    FROM cust
)

SELECT
    quintile,

    ROUND(
        100.0 * SUM(rev) /
        (SELECT SUM(rev) FROM cust),
        1
    ) AS pct_of_revenue

FROM r

GROUP BY quintile

ORDER BY quintile;T SUM(rev) FROM cust),1) AS pct_of_revenue FROM r GROUP BY quintile ORDER BY quintile;

-- 7. Repeat-purchase rate
-- 7. Repeat-purchase rate

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders

    FROM orders

    WHERE status = 'Delivered'

    GROUP BY customer_id
)

SELECT
    ROUND(
        100.0 * COUNT(CASE
            WHEN total_orders > 1 THEN 1
        END) / NULLIF(COUNT(*), 0),
        1
    ) AS repeat_customer_pct

FROM customer_orders;

-- 8. Revenue by state and channel
S-- 8. Revenue by state and channel

SELECT
    COALESCE(c.state, 'Unknown') AS state,
    o.channel,

    ROUND(SUM(
        oi.quantity * p.unit_price *
        (1 - oi.discount_pct / 100.0)
    ), 0) AS revenue

FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id

WHERE o.status = 'Delivered'

GROUP BY
    COALESCE(c.state, 'Unknown'),
    o.channel

ORDER BY revenue DESC

LIMIT 15;

-- 9. Does discounting pay off? Avg quantity and margin by discount level
-- 9. Average quantity and margin by discount level

SELECT
    oi.discount_pct,

    COUNT(*) AS line_items,

    ROUND(AVG(oi.quantity), 2) AS avg_qty,

    ROUND(
        100.0 * SUM(
            oi.quantity *
            (p.unit_price * (1 - oi.discount_pct / 100.0) - p.unit_cost)
        )
        / NULLIF(SUM(
            oi.quantity * p.unit_price *
            (1 - oi.discount_pct / 100.0)
        ), 0),
        1
    ) AS margin_pct

FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id

WHERE o.status = 'Delivered'

GROUP BY oi.discount_pct

ORDER BY oi.discount_pct;