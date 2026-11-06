describe order_items
-- =========================================================
-- QUERY 2: Check Missing Values in Order Items
-- PURPOSE: Identify NULL and blank values across all columns.
-- =========================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL OR TRIM(order_id) = '') AS missing_order_id,
    SUM(product_id IS NULL OR TRIM(product_id) = '') AS missing_product_id,
    SUM(quantity IS NULL) AS missing_quantity,
    SUM(discount_pct IS NULL) AS missing_discount
FROM order_items;

-- =========================================================
-- QUERY 3: Identify Exact Duplicate Order Items
-- PURPOSE: Find records that are identical across all four columns.
-- =========================================================

SELECT
    order_id,
    product_id,
    quantity,
    discount_pct,
    COUNT(*) AS occurrences
FROM order_items
GROUP BY
    order_id,
    product_id,
    quantity,
    discount_pct
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- =========================================================
-- QUERY 4: Identify Invalid Order Quantities
-- PURPOSE: Find order items with zero or negative quantities.
-- =========================================================

SELECT *
FROM order_items
WHERE quantity <= 0;

-- =========================================================
-- QUERY 5: Identify Invalid Discount Percentages
-- PURPOSE: Find discounts outside the valid 0–100 range.
-- =========================================================

SELECT *
FROM order_items
WHERE discount_pct < 0
   OR discount_pct > 100;
   
-- =========================================================
-- QUERY 6: Check Invalid Order References
-- PURPOSE: Identify order items without a matching order record.
-- =========================================================

SELECT
    oi.order_id
FROM order_items AS oi
LEFT JOIN orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- =========================================================
-- QUERY 7: Check Invalid Product References
-- PURPOSE: Identify order items without a matching product record.
-- =========================================================

SELECT
    oi.product_id
FROM order_items AS oi
LEFT JOIN products AS p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- =========================================================
-- QUERY 8: Identify Repeated Order-Product Combinations
-- PURPOSE: Find products appearing multiple times within the same order.
-- =========================================================

SELECT
    order_id,
    product_id,
    COUNT(*) AS occurrences
FROM order_items        -- returned 150 repeated order-product combinations
GROUP BY
    order_id,
    product_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- =========================================================
-- QUERY 9: Inspect Repeated Order-Product Records
-- PURPOSE: Examine individual records for repeated order-product combinations.
-- =========================================================

SELECT *
FROM order_items
WHERE order_id = 'O002502' -- these are not exact duplicates are quantity and 
  AND product_id = 'P0090';
  
  
  -- =========================================================
-- QUERY 10: Classify Repeated Order-Product Combinations
-- PURPOSE: Distinguish exact duplicate groups from other repeated combinations.
-- =========================================================

SELECT
    COUNT(*) AS repeated_combinations,
    SUM(
        CASE
            WHEN exact_variants = 1 THEN 1
            ELSE 0
        END
    ) AS exact_duplicate_combinations,
    SUM(
        CASE
            WHEN exact_variants > 1 THEN 1
            ELSE 0
        END
    ) AS different_line_item_combinations
FROM (
    SELECT
        order_id,
        product_id,
        COUNT(DISTINCT quantity, discount_pct) AS exact_variants
    FROM order_items
    GROUP BY order_id, product_id
    HAVING COUNT(*) > 1
) AS repeated_items;

-- =========================================================
-- QUERY 11: Calculate Excess Duplicate Rows
-- PURPOSE: Calculate how many exact duplicate rows can be removed.
-- =========================================================

SELECT
    SUM(occurrences - 1) AS excess_duplicate_rows
FROM (
    SELECT
        order_id,
        product_id,
        quantity,
        discount_pct,
        COUNT(*) AS occurrences
    FROM order_items
    GROUP BY
        order_id,
        product_id,
        quantity,
        discount_pct
    HAVING COUNT(*) > 1
) AS duplicates;

-- =========================================================
-- QUERY 1: Create Clean Order Items Table
-- PURPOSE: Remove exact duplicate records while preserving distinct line items.
-- =========================================================

CREATE TABLE order_items_clean AS
SELECT DISTINCT
    order_id,
    product_id,
    quantity,
    discount_pct
FROM order_items;