-- Creating the database for the project
CREATE DATABASE sqlproject;

-- Importing the dataset into the SQL Server for analysis
-- The dataset is named 'EV_Dataset'
-- Assumes the data has been successfully imported.

-- General Sales Analysis
-- This section analyzes EV sales trends over time.

-- 1) Yearly EV sales trend: Analyze if sales are increasing or decreasing over the years.
SELECT 
    year, 
    SUM(EV_Sales_Quantity) AS Total_Sales 
FROM 
    EV_Dataset 
GROUP BY 
    year 
ORDER BY 
    year;

-- Observations:
-- Sales have increased consistently from 2014 to 2023.
-- However, there is a decline in 2024.

-- 2) Monthly EV sales trends: Identifying months with highest and lowest sales across years.
SELECT 
    year, 
    Month_Name, 
    SUM(EV_Sales_Quantity) AS Total_Sales 
FROM 
    EV_Dataset 
GROUP BY 
    year, Month_Name 
ORDER BY 
    Total_Sales;

-- Observations:
-- Months like January, February, and March generally show higher sales.


-- Regional Insights
-- This section focuses on state-wise EV sales analysis.

-- 3) States with the highest and lowest EV sales.
-- State with the highest total EV sales:
SELECT TOP 1 
    state, 
    SUM(EV_Sales_Quantity) AS Total_Sales 
FROM 
    EV_Dataset 
GROUP BY 
    state 
ORDER BY 
    Total_Sales DESC;

-- Observations:
-- Uttar Pradesh has the highest EV sales.

-- State with the lowest total EV sales:
SELECT TOP 1 
    state, 
    SUM(EV_Sales_Quantity) AS Total_Sales 
FROM 
    EV_Dataset 
GROUP BY 
    state 
ORDER BY 
    Total_Sales;

-- Observations:
-- Sikkim has the lowest EV sales.

-- 4) State with the highest average sales per year:
SELECT TOP 1 
    state, 
    AVG(EV_Sales_Quantity) AS Avg_Sales_Per_Year
FROM 
    EV_Dataset
GROUP BY 
    state
ORDER BY 
    Avg_Sales_Per_Year DESC;

-- Observations:
-- Delhi has the highest average sales per year.

-- Vehicle Class & Category Analysis
-- This section explores which categories and classes of vehicles dominate EV sales.

-- 5) Top-selling vehicle categories and classes:
-- Top-selling categories:
SELECT TOP 5  
    Vehicle_Category, 
    SUM(EV_Sales_Quantity) AS Total_Sales
FROM 
    EV_Dataset 
GROUP BY 
    Vehicle_Category 
ORDER BY 
    Total_Sales DESC;

-- Observations:
-- 2-Wheelers and 3-Wheelers are the top-selling categories.

-- Top-selling vehicle classes:
SELECT TOP 5  
    Vehicle_Class, 
    SUM(EV_Sales_Quantity) AS Total_Sales
FROM 
    EV_Dataset 
GROUP BY 
    Vehicle_Class 
ORDER BY 
    Total_Sales DESC;

-- Observations:
-- M-CYCLE/SCOOTER and E-RICKSHAW(P) are the top-selling vehicle classes.

-- 6) Percentage contribution of each vehicle category to total sales:
WITH category_total AS (
    SELECT 
        Vehicle_Category, 
        SUM(EV_Sales_Quantity) AS total_sales
    FROM 
        EV_Dataset
    GROUP BY 
        Vehicle_Category
),
total_sales AS (
    SELECT 
        SUM(EV_Sales_Quantity) AS overall_sales
    FROM 
        EV_Dataset
)
SELECT 
    ct.Vehicle_Category, 
    ct.total_sales, 
    ts.overall_sales, 
    (ct.total_sales * 1.0 / ts.overall_sales) * 100 AS percentage_of_sales
FROM 
    category_total ct, 
    total_sales ts 
ORDER BY 
    percentage_of_sales;

-- Observations:
-- 2-Wheelers contribute the highest percentage of total sales (~51%).

-- Comparative Insights
-- This section provides comparisons between states and years.

-- 7) States with the largest YoY (Year-over-Year) sales increase or decrease:
WITH SalesByYear AS (
    SELECT 
        state, 
        year, 
        SUM(EV_Sales_Quantity) AS Total_Sales
    FROM 
        EV_Dataset
    GROUP BY 
        state, year
),
YoY_Changes AS (
    SELECT 
        state, 
        year, 
        Total_Sales,
        Total_Sales - LAG(Total_Sales) OVER (PARTITION BY state ORDER BY year) AS YoY_Change
    FROM 
        SalesByYear
)
SELECT 
    state, 
    year, 
    YoY_Change
FROM 
    YoY_Changes
WHERE 
    YoY_Change = (SELECT MAX(YoY_Change) FROM YoY_Changes) 
    OR YoY_Change = (SELECT MIN(YoY_Change) FROM YoY_Changes);

-- Observations:
-- Maharashtra saw the largest decrease in 2024.
-- Uttar Pradesh saw the largest increase in 2023.

-- State vs Vehicle Class
-- 8) Leading states in specific vehicle classes:
WITH RankedStates AS (
    SELECT 
        vehicle_class, 
        state, 
        SUM(EV_Sales_Quantity) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY vehicle_class ORDER BY SUM(EV_Sales_Quantity) DESC) AS rank
    FROM 
        EV_Dataset
    GROUP BY 
        vehicle_class, state
)
SELECT 
    vehicle_class, 
    state, 
    total_sales
FROM 
    RankedStates
WHERE 
    rank = 1 AND not total_sales = 0
ORDER BY 
    vehicle_class, rank;

-- Observations:
-- Uttar Pradesh is a leader in E-RICKSHAW(P) and related vehicle classes.
-- Maharashtra leads in M-CYCLE/SCOOTER sales.