describe orders

-- =========================================================
-- QUERY 1: Check Missing Values in Orders
-- PURPOSE: Count NULL, empty-string, and whitespace-only values.
-- =========================================================

SELECT
    COUNT(*) AS total_rows,

    SUM(order_id IS NULL OR TRIM(order_id) = '')
        AS missing_order_id,

    SUM(customer_id IS NULL OR TRIM(customer_id) = '')
        AS missing_customer_id,

    SUM(order_date IS NULL)
        AS missing_order_date,

    SUM(channel IS NULL OR TRIM(channel) = '')
        AS missing_channel,

    SUM(payment_method IS NULL OR TRIM(payment_method) = ''). --- no empty values
        AS missing_payment_method,

    SUM(status IS NULL OR TRIM(status) = '')
        AS missing_status

FROM orders;

sql
-- =========================================================
-- QUERY 2: Check Duplicate Order IDs
-- PURPOSE: Identify order IDs that appear more than once.
-- =========================================================

SELECT
    order_id,
    COUNT(*) AS occurrences
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- =========================================================
-- QUERY 3: Find Orders with Invalid Customer IDs
-- PURPOSE: Identify orders whose customer_id does not exist in customers.
-- =========================================================

SELECT
    o.order_id,
    o.customer_id
FROM orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- =========================================================
-- QUERY 4: Find Leading or Trailing Spaces
-- PURPOSE: Identify extra spaces in text columns.
-- =========================================================

SELECT
    order_id,
    customer_id,
    channel,
    payment_method,
    status
FROM orders
WHERE (order_id IS NOT NULL AND order_id <> TRIM(order_id))
   OR (customer_id IS NOT NULL AND customer_id <> TRIM(customer_id))
   OR (channel IS NOT NULL AND channel <> TRIM(channel))
   OR (payment_method IS NOT NULL AND payment_method <> TRIM(payment_method))
   OR (status IS NOT NULL AND status <> TRIM(status));

-- =========================================================
-- QUERY 5: Inspect Distinct Order Statuses
-- PURPOSE: Identify unique order statuses and potential inconsistencies.
-- =========================================================

SELECT DISTINCT status
FROM orders
ORDER BY status;

-- =========================================================
-- QUERY 6: Inspect Distinct Order Channels
-- PURPOSE: Identify unique sales channels and potential inconsistencies.
-- =========================================================

SELECT DISTINCT channel
FROM orders
ORDER BY channel;

-- =========================================================
-- QUERY 8: Check Order Date Range
-- PURPOSE: Identify the earliest and latest order dates.
-- =========================================================

SELECT
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order
FROM orders;

-- =========================================================
-- QUERY 9: Check 2025 Orders Against Customer Signup Dates
-- PURPOSE: Verify whether customers who signed up by 2024 placed orders in 2025.
-- =========================================================

SELECT
    COUNT(*) AS orders_in_2025,
    COUNT(DISTINCT o.customer_id) AS customers_ordering_in_2025
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE YEAR(o.order_date) = 2025;

-- =========================================================
-- QUERY 1: Create Clean Orders Table
-- PURPOSE: Create a clean copy of the orders table.
-- =========================================================

CREATE TABLE orders_clean AS
SELECT
    order_id,
    customer_id,
    order_date,
    channel,
    payment_method,
    status
FROM orders;

