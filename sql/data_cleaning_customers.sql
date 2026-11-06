-- =========================================================
-- QUERY 1: Identify Missing and Blank Values
-- PURPOSE: Count missing values in each customer column.
-- =========================================================
SELECT 
    COUNT(*) AS total_rows,
    SUM(customer_id IS NULL
        OR TRIM(customer_id) = '') AS missing_customer_id,
    SUM(state IS NULL OR TRIM(state) = '') AS missing_state,
    SUM(signup_date IS NULL) AS missing_signup_date,
    SUM(segment IS NULL OR TRIM(segment) = '') AS missing_segment
FROM
    customers;

-- =========================================================
-- QUERY 2: Inspect Customers with Missing States
-- PURPOSE: View records where state is NULL or blank.
-- =========================================================
SELECT 
    customer_id, state, signup_date, segment
FROM
    customers
WHERE
    state IS NULL OR TRIM(state) = '';
												-- here we i just discovered that the 60 empty values are not null they are spaces

SELECT 
    COUNT(*)
FROM
    customers
WHERE
    state IS NULL OR TRIM(state) = '';

-- =========================================================
-- QUERY 3: Check Duplicate Customer IDs
-- PURPOSE: Identify customer IDs appearing more than once.
-- =========================================================

SELECT 
    customer_id, COUNT(*) AS occurance
FROM
    customers
GROUP BY customer_id
HAVING COUNT(*) > 1;  -- there are no duplicate customer_id


-- =========================================================
-- QUERY 4: Find Leading or Trailing Spaces
-- PURPOSE: Identify state and segment values with extra spaces.
-- =========================================================
select customer_id ,state ,segment from customers
where (state IS NOT NULL AND state <> TRIM(state))
   OR (segment IS NOT NULL AND segment <> TRIM(segment))

-- =========================================================
-- QUERY 5: Inspect Distinct State Values
-- PURPOSE: List unique state names to identify inconsistencies.
-- =========================================================

SELECT DISTINCT state
FROM customers
WHERE state IS NOT NULL
  AND TRIM(state) <> ''
ORDER BY state;

-- =========================================================
-- QUERY 6: Inspect Distinct Customer Segments
-- PURPOSE: Identify unique customer segments and potential inconsistencies.
-- =========================================================

SELECT DISTINCT
    segment
FROM
    customers
WHERE
    segment IS NOT NULL
        AND TRIM(segment) <> ''
ORDER BY segment;

-- =========================================================

SELECT 
    customer_id, signup_date
FROM
    customers
WHERE
    signup_date > CURDATE();

-- =========================================================
-- QUERY 8: Check Signup Date Range
-- PURPOSE: Identify the earliest and latest customer signup dates.
-- =========================================================

SELECT 
    MIN(signup_date) AS earliest_signup_date,
    MAX(signup_date) AS latest_signup_date
FROM
    customers;

-- =========================================================
-- QUERY 9: Confirm Total Customer Records
-- PURPOSE: Verify the total number of customer records.
-- =========================================================

SELECT 
    COUNT(*) AS total_customers
FROM
    customers;

-- =========================================================
-- QUERY 1: Create Clean Customers Table
-- PURPOSE: Convert empty state values to NULL while preserving all customer records.
-- =========================================================

CREATE TABLE customers_clean AS
SELECT
    customer_id,
    NULLIF(TRIM(state), '') AS state,
    signup_date,
    segment
FROM customers;
