
DESCRIBE products;


-- =========================================================
-- QUERY 1: Check Missing Values in All Columns
-- PURPOSE: Count NULL, empty-string, and whitespace-only values.
-- =========================================================

SELECT
    COUNT(*) AS total_rows,

    SUM(product_id IS NULL OR TRIM(product_id) = '')
        AS missing_product_id,

    SUM(product_name IS NULL OR TRIM(product_name) = '')
        AS missing_product_name,

    SUM(category IS NULL OR TRIM(category) = '')		-- 0 missing values
        AS missing_category,

    SUM(unit_price IS NULL)
        AS missing_unit_price,

    SUM(unit_cost IS NULL)
        AS missing_unit_cost

FROM products;


-- =========================================================
-- QUERY 2: Check Duplicate Product IDs
-- PURPOSE: Identify product IDs that appear more than once.
-- =========================================================

SELECT 
    product_id, COUNT(*) AS occurrences
FROM
    products
GROUP BY product_id					-- Zero rows returned means no duplicate product_id values were found.
HAVING COUNT(*) > 1;

-- =========================================================
-- QUERY 3: Check Invalid Prices and Costs
-- PURPOSE: Identify zero or negative prices and costs.
-- =========================================================

SELECT
    product_id,
    product_name,
    unit_price,
    unit_cost			--  Zero rows returned means all 150 products have positive selling prices and positive unit costs.
FROM products
WHERE unit_price <= 0
   OR unit_cost <= 0;
   

-- =========================================================
-- QUERY 4: Find Products with Cost Above Selling Price
-- PURPOSE: Identify products with a negative gross profit per unit.
-- =========================================================

SELECT
    product_id,
    product_name,   -- Zero rows returned means all 150 products have a unit cost less than or equal to their selling price.
    category,
    unit_price,
    unit_cost,
    unit_price - unit_cost AS profit_per_unit 
FROM products
WHERE unit_cost > unit_price
ORDER BY profit_per_unit;

-- =========================================================
-- QUERY 5: Find Leading or Trailing Spaces
-- PURPOSE: Identify extra spaces in product names and categories.
-- =========================================================

SELECT
    product_id,
    product_name,  -- Zero rows returned means no leading or trailing spaces were detected in product_name or category.
    category
FROM products
WHERE (product_name IS NOT NULL AND product_name <> TRIM(product_name))
   OR (category IS NOT NULL AND category <> TRIM(category));
   
   
-- =========================================================
-- QUERY 6: Inspect Distinct Product Categories
-- PURPOSE: Identify unique category names and potential inconsistencies.
-- =========================================================

SELECT DISTINCT category
FROM products
WHERE category IS NOT NULL
  AND TRIM(category) <> ''
ORDER BY category;

-- =========================================================
-- QUERY 7: Check for Duplicate Product Names
-- PURPOSE: Identify product names associated with multiple product IDs.
-- =========================================================

SELECT
    product_name,
    COUNT(*) AS occurrences
FROM products
GROUP BY product_name
HAVING COUNT(*) > 1     -- Zero rows returned means every product name is unique in your products table
ORDER BY occurrences DESC;

-- =========================================================
-- QUERY 1: Create Clean Products Table
-- PURPOSE: Create a clean copy of the products table.
-- =========================================================

CREATE TABLE products_clean AS
SELECT
    product_id,
    product_name,
    category,
    unit_price,
    unit_cost
FROM products;



