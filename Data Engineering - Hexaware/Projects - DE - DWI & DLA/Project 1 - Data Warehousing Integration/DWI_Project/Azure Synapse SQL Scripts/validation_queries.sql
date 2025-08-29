------------------------------------------------------
-- 04_validation_queries.sql
-- Purpose: Validate curated tables after ETL + load
------------------------------------------------------


-- 1. Row counts in each table
SELECT COUNT(*) AS fact_sales_count FROM dbo.fact_sales;
SELECT COUNT(*) AS dim_customer_count FROM dbo.dim_customer;
SELECT COUNT(*) AS dim_product_count FROM dbo.dim_product;
SELECT COUNT(*) AS dim_date_count FROM dbo.dim_date;

-- 2. Check for orphaned Product_IDs in fact
SELECT DISTINCT f.Product_ID
FROM dbo.fact_sales f
LEFT JOIN dbo.dim_product p ON f.Product_ID = p.Product_ID
WHERE p.Product_ID IS NULL;

-- 3. Check for orphaned Date_IDs in fact
SELECT DISTINCT f.Date_ID
FROM dbo.fact_sales f
LEFT JOIN dbo.dim_date d ON f.Date_ID = d.Date_ID
WHERE d.Date_ID IS NULL;

-- 4. Sales by product category
SELECT p.Product_Category, SUM(f.Total_Amount) AS total_sales
FROM dbo.fact_sales f
JOIN dbo.dim_product p ON f.Product_ID = p.Product_ID
GROUP BY p.Product_Category
ORDER BY total_sales DESC;

-- 5. Sales by gender
SELECT c.Gender, SUM(f.Total_Amount) AS total_sales
FROM dbo.fact_sales f
JOIN dbo.dim_customer c ON f.Customer_ID = c.Customer_ID
GROUP BY c.Gender;

-- 6. Sales trend by month (quick time sanity check)
SELECT d.Year, d.Month, SUM(f.Total_Amount) AS monthly_sales
FROM dbo.fact_sales f
JOIN dbo.dim_date d ON f.Date_ID = d.Date_ID
GROUP BY d.Year, d.Month
ORDER BY d.Year, d.Month;

-- 7. Age group sales contribution
SELECT 
    CASE 
        WHEN c.Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN c.Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN c.Age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END AS Age_Group,
    SUM(f.Total_Amount) AS total_sales
FROM dbo.fact_sales f
JOIN dbo.dim_customer c ON f.Customer_ID = c.Customer_ID
GROUP BY CASE 
        WHEN c.Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN c.Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN c.Age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END
ORDER BY total_sales DESC;

-- 8. Top 10 customers by spend
SELECT TOP 10 f.Customer_ID, SUM(f.Total_Amount) AS customer_spend
FROM dbo.fact_sales f
GROUP BY f.Customer_ID
ORDER BY customer_spend DESC;