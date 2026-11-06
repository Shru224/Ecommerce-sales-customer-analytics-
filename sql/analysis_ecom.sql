-- =========================================================
-- QUERY 1: Headline Business KPIs
-- PURPOSE: Calculate revenue, profit, total orders and average order value for delivered orders.
-- =========================================================

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

FROM orders_clean o
JOIN order_items_clean oi ON o.order_id = oi.order_id
JOIN products_clean p ON oi.product_id = p.product_id

WHERE o.status = 'Delivered';


-- =========================================================
-- QUERY 2: Monthly Revenue and MoM Growth
-- PURPOSE: Analyse monthly revenue trends and month-over-month growth.
-- =========================================================

WITH monthly AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        SUM(
            oi.quantity * p.unit_price *
            (1 - oi.discount_pct / 100.0)
        ) AS revenue

    FROM orders_clean o
    JOIN order_items_clean oi ON o.order_id = oi.order_id
    JOIN products_clean p ON oi.product_id = p.product_id

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


-- =========================================================
-- QUERY 3: Category Revenue, Profit and Margin
-- PURPOSE: Compare financial performance across product categories.
-- =========================================================

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

FROM orders_clean o
JOIN order_items_clean oi ON o.order_id = oi.order_id
JOIN products_clean p ON oi.product_id = p.product_id

WHERE o.status = 'Delivered'

GROUP BY p.category
ORDER BY revenue DESC;


-- =========================================================
-- QUERY 4: Top 3 Products per Category
-- PURPOSE: Rank products within each category based on revenue.
-- =========================================================

WITH prod_rev AS (
    SELECT
        p.category,
        p.product_name,

        SUM(
            oi.quantity * p.unit_price *
            (1 - oi.discount_pct / 100.0)
        ) AS revenue

    FROM orders_clean o
    JOIN order_items_clean oi ON o.order_id = oi.order_id
    JOIN products_clean p ON oi.product_id = p.product_id

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


-- =========================================================
-- QUERY 5: Customer Lifetime Value
-- PURPOSE: Identify the top 10 customers based on lifetime revenue.
-- =========================================================

SELECT
    c.customer_id,
    c.state,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(SUM(
        oi.quantity * p.unit_price *
        (1 - oi.discount_pct / 100.0)
    ), 0) AS lifetime_value

FROM customers_clean c
JOIN orders_clean o ON c.customer_id = o.customer_id
JOIN order_items_clean oi ON o.order_id = oi.order_id
JOIN products_clean p ON oi.product_id = p.product_id

WHERE o.status = 'Delivered'

GROUP BY c.customer_id, c.state

ORDER BY lifetime_value DESC

LIMIT 10;


-- =========================================================
-- QUERY 6: Revenue Contribution by Customer Quintile
-- PURPOSE: Measure the percentage of revenue contributed by each customer group.
-- =========================================================

WITH cust AS (
    SELECT
        o.customer_id,

        SUM(
            oi.quantity * p.unit_price *
            (1 - oi.discount_pct / 100.0)
        ) AS rev

    FROM orders_clean o
    JOIN order_items_clean oi ON o.order_id = oi.order_id
    JOIN products_clean p ON oi.product_id = p.product_id

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

ORDER BY quintile;


-- =========================================================
-- QUERY 7: Repeat Purchase Rate
-- PURPOSE: Calculate the percentage of customers who made more than one delivered order.
-- =========================================================

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders

    FROM orders_clean

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


-- =========================================================
-- QUERY 8: Revenue by State and Channel
-- PURPOSE: Analyse revenue distribution across customer states and sales channels.
-- =========================================================

SELECT
    COALESCE(c.state, 'Unknown') AS state,
    o.channel,

    ROUND(SUM(
        oi.quantity * p.unit_price *
        (1 - oi.discount_pct / 100.0)
    ), 0) AS revenue

FROM orders_clean o
JOIN customers_clean c ON o.customer_id = c.customer_id
JOIN order_items_clean oi ON o.order_id = oi.order_id
JOIN products_clean p ON oi.product_id = p.product_id

WHERE o.status = 'Delivered'

GROUP BY
    COALESCE(c.state, 'Unknown'),
    o.channel

ORDER BY revenue DESC

LIMIT 15;


-- =========================================================
-- QUERY 9: Discount Impact on Quantity and Profit Margin
-- PURPOSE: Evaluate average quantity and profit margin across discount levels.
-- =========================================================

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

FROM order_items_clean oi
JOIN products_clean p ON oi.product_id = p.product_id
JOIN orders_clean o ON oi.order_id = o.order_id

WHERE o.status = 'Delivered'

GROUP BY oi.discount_pct

ORDER BY oi.discount_pct;
