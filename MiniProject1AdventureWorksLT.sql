-- Question 1: Provide the top 10 customers (full name) by revenue, the country they shipped to, the cities and their revenue (orderqty * unitprice)

-- Step 1: Select relevant columns and calculate total revenue
SELECT TOP 10
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName, -- Concatenate first and last names for readability
    a.City,
    a.CountryRegion AS Country, -- Alias for clarity
    SUM(sod.OrderQty * sod.UnitPrice) AS TotalRevenue -- Calculate total revenue per customer
FROM 
    SalesLT.Customer AS c -- Step 2: Join Customer table
    INNER JOIN SalesLT.SalesOrderHeader AS soh 
        ON c.CustomerID = soh.CustomerID -- Step 3: Link customers to their orders
    INNER JOIN SalesLT.SalesOrderDetail AS sod 
        ON soh.SalesOrderID = sod.SalesOrderID -- Step 4: Link orders to order details
    INNER JOIN SalesLT.Address AS a 
        ON soh.ShipToAddressID = a.AddressID -- Step 5: Link orders to shipping address
GROUP BY 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    a.City,
    a.CountryRegion -- Step 6: Group by customer and location to aggregate revenue
ORDER BY 
    TotalRevenue DESC; -- Step 7: Sort by total revenue in descending order to get top 10


-- Question 2: Create 4 distinct customer segments using the total Revenue(orderqty * unitprice) by customer. List the customer details (ID, Company Name), Revenue and the segment the customer belongs to

-- Step 1: Select customer details and calculate total revenue
SELECT 
    c.CustomerID,
    c.CompanyName,
    SUM(sod.OrderQty * sod.UnitPrice) AS TotalRevenue, -- Calculate revenue from order quantities and prices
    CASE 
        WHEN SUM(sod.OrderQty * sod.UnitPrice) >= 50000 THEN 'High Patronage'   -- Revenue >= 50,000
        WHEN SUM(sod.OrderQty * sod.UnitPrice) >= 25000 THEN 'Medium Patronage' -- Revenue >= 25,000
        WHEN SUM(sod.OrderQty * sod.UnitPrice) >= 10000 THEN 'Low Patronage'    -- Revenue >= 10,000
        WHEN SUM(sod.OrderQty * sod.UnitPrice) >= 5000 THEN 'Very Low Patronage' -- Revenue >= 5,000
        ELSE 'Minimal Patronage' -- Revenue < 5,000, updated label for clarity
    END AS CustomerSegment
FROM 
    SalesLT.Customer AS c
    INNER JOIN SalesLT.SalesOrderHeader AS soh 
        ON c.CustomerID = soh.CustomerID -- Step 2: Link customers to their orders
    INNER JOIN SalesLT.SalesOrderDetail AS sod 
        ON soh.SalesOrderID = sod.SalesOrderID -- Step 3: Link orders to order details
GROUP BY 
    c.CustomerID,
    c.CompanyName -- Step 4: Group by customer for revenue aggregation
ORDER BY 
    TotalRevenue DESC; -- Step 5: Sort by total revenue in descending order

-- Question 3: What products with their respective categories did our customers buy on our last day of business? List the CustomerID, Product ID, Product Name, Category Name and Order Date

-- Query to retrieve customer orders from the most recent order date, including product and category details
-- Best practices applied: clear comments, consistent formatting, table aliases, explicit column naming, and optimized subquery

-- Step 1: Select customer, product, and category details for orders on the latest order date
SELECT 
    soh.CustomerID,
    p.ProductID,
    p.Name AS ProductName, -- Alias for clarity
    pc.Name AS CategoryName, -- Alias for clarity
    soh.OrderDate
FROM 
    SalesLT.SalesOrderHeader AS soh
    INNER JOIN SalesLT.SalesOrderDetail AS sod 
        ON soh.SalesOrderID = sod.SalesOrderID -- Step 2: Link orders to order details
    INNER JOIN SalesLT.Product AS p 
        ON sod.ProductID = p.ProductID -- Step 3: Link order details to products
    INNER JOIN SalesLT.ProductCategory AS pc 
        ON p.ProductCategoryID = pc.ProductCategoryID -- Step 4: Link products to categories
WHERE 
    soh.OrderDate = (
        SELECT MAX(OrderDate) 
        FROM SalesLT.SalesOrderHeader
    ); -- Step 5: Filter for orders matching the most recent order date

	-- Question 4: Create a View for Customer Segmentation
	-- Script to create or replace a view for customer segmentation and analyze the results
-- Best practices applied: clear comments, consistent formatting, table aliases, explicit column naming, and modular structure

-- Step 1: Check if the view exists and drop it to avoid conflicts
IF OBJECT_ID('SalesLT.CustomerSegment', 'V') IS NOT NULL
    DROP VIEW SalesLT.CustomerSegment;
GO

-- Step 2: Create a view to categorize customers into segments based on revenue
CREATE VIEW SalesLT.CustomerSegment
AS
SELECT 
    c.CustomerID AS ID, -- Alias for clarity
    c.CompanyName AS Name, -- Alias for clarity
    SUM(sod.OrderQty * sod.UnitPrice) AS Revenue, -- Calculate total revenue
    CASE 
        WHEN SUM(sod.OrderQty * sod.UnitPrice) >= 10000 THEN 'Platinum' -- Revenue >= 10,000
        WHEN SUM(sod.OrderQty * sod.UnitPrice) >= 5000 THEN 'Gold'     -- Revenue >= 5,000
        WHEN SUM(sod.OrderQty * sod.UnitPrice) >= 1000 THEN 'Silver'   -- Revenue >= 1,000
        ELSE 'Bronze' -- Revenue < 1,000
    END AS Segment
FROM 
    SalesLT.Customer AS c
    INNER JOIN SalesLT.SalesOrderHeader AS soh 
        ON c.CustomerID = soh.CustomerID -- Link customers to their orders
    INNER JOIN SalesLT.SalesOrderDetail AS sod 
        ON soh.SalesOrderID = sod.SalesOrderID -- Link orders to order details
GROUP BY 
    c.CustomerID,
    c.CompanyName; -- Group by customer for revenue aggregation
GO

-- Step 3: Query all data from the CustomerSegment view
SELECT 
    ID,
    Name,
    Revenue,
    Segment
FROM 
    SalesLT.CustomerSegment;

-- Step 4: Count the number of customers in the Platinum segment
SELECT 
    Segment,
    COUNT(*) AS CustomerCount -- Alias for clarity
FROM 
    SalesLT.CustomerSegment
WHERE 
    Segment = 'Platinum'
GROUP BY 
    Segment;

-- Question 5: Top 3 selling products in each category by revenue

-- Step 1: Calculate total revenue per product using a Common Table Expression (CTE)
WITH ProductRevenue AS (
    SELECT 
        p.ProductID,
        p.Name AS ProductName, -- Alias for clarity
        pc.Name AS CategoryName, -- Alias for clarity
        SUM(sod.OrderQty * sod.UnitPrice) AS TotalRevenue -- Aggregate revenue from order quantities and prices
    FROM 
        SalesLT.SalesOrderDetail AS sod
        INNER JOIN SalesLT.Product AS p 
            ON sod.ProductID = p.ProductID -- Link order details to products
        INNER JOIN SalesLT.ProductCategory AS pc 
            ON p.ProductCategoryID = pc.ProductCategoryID -- Link products to categories
    GROUP BY 
        p.ProductID,
        p.Name,
        pc.Name -- Group by product and category for revenue calculation
),
-- Step 2: Rank products within each category based on revenue
RankedProducts AS (
    SELECT 
        ProductID,
        ProductName,
        CategoryName,
        TotalRevenue,
        RANK() OVER (PARTITION BY CategoryName ORDER BY TotalRevenue DESC) AS RankNum -- Rank products within each category
    FROM 
        ProductRevenue
)
-- Step 3: Select only the top 3 products per category and order results
SELECT 
    ProductID,
    ProductName,
    CategoryName,
    TotalRevenue,
    RankNum
FROM 
    RankedProducts
WHERE 
    RankNum <= 3 -- Filter for top 3 products in each category
ORDER BY 
    CategoryName, 
    RankNum; -- Sort by category and rank for clear presentation


    Use SalesDB

    -- Write a query to rank customers based on their sales,  the result should include the customer's customerID, Full Name, Country, Sales and their rank
    -- Three possible ways to write the query
    -- Using CTE

    With CustomersSales As (
     Select 
        c.CustomerID,
        concat(coalesce (c.FirstName,''),' ',coalesce(c.LastName,'')) as FullName,
        c.Country,
       Sum(o.Sales) as TotalSales
    From sales.Customers c Inner Join sales.Orders o
    On c.customerID = o.CustomerID
    Group by c.CustomerID,c.FirstName,c.LastName,c.Country
    
) 
Select 
    CustomerID,
    FullName,
    Country,
    TotalSales,
    Rank() over( order by TotalSales DESC) as RankNo
From CustomersSales

--Using Subquery

 Select 
        c.CustomerID,
        concat(coalesce (c.FirstName,''),' ',coalesce(c.LastName,'')) as FullName,
        c.Country,
        TotalSales,
       Rank() over(order by TotalSales DESC) RankNo
    From sales.Customers c Inner Join (select customerID,sum(Sales) TotalSales From sales.orders group by CustomerID) o
    On c.customerID = o.CustomerID
    
-- Using Single query
 Select 
        c.CustomerID,
        concat(coalesce (c.FirstName,''),' ',coalesce(c.LastName,'')) as FullName,
        c.Country,
       Sum(o.Sales) as TotalSales,
       Rank() over(order by sum(o.Sales) DESC) RankNo
    From sales.Customers c Inner Join sales.Orders o
    On c.customerID = o.CustomerID
    Group by c.CustomerID,c.FirstName,c.LastName,c.Country
    
