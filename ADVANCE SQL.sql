--5 IMPORTANT TECHNIQUES IN SQL
--1. SUBQUERY
--2. VIEW
--3.COMMON TABLE EXPRESSION
--4. TEMPORARY TABLE 
--5. CTAS CREATE TABLE AS SELECT
SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	--SUBQUERY 
	--@ from claue		 
SELECT *
	FROM
	(
SELECT 
	ORDERID,
	PRODUCTID
																			-- OUTER QUERY CALLED MAIN QUERY																		 -- INNER QUERY CALLED SUBQUERY 
	SALES,
	MIN(SALES) OVER(PARTITION BY PRODUCTID ) LOWESTSALES,
	MAX(SALES) OVER(PARTITION BY PRODUCTID ) HIGHESTSALES
	FROM SALES.ORDERS)t
	WHERE SALES = LOWESTSALES OR SALES = HIGHESTSALES
	--

-- SHOW THE PRODUCTID, PRODUCT NAMES, PRICES,  AND TOTAL NUMBER OF ORDERS
SELECT 
	PRODUCTID,
	Product,
	PRICE,
	(SELECT COUNT(*) FROM SALES.ORDERS) AS TOTALODERS
	FROM sales.PRODUCTS

	SELECT 
    p.ProductID,
    p.Product,
    p.Price,
    o.TotalOrders
FROM Sales.Products p
LEFT JOIN (
    SELECT ProductID, COUNT(*) AS TotalOrders
    FROM Sales.Orders
    GROUP BY ProductID
) o 
    ON p.ProductID = o.ProductID;


	SELECT * FROM SALES.ORDERS;
	SELECT * FROM SALES.Products;
	-- find the products that have a price higher than the
	--average price of all products
SELECT
	*
	FROM	
(SELECT 
	PRODUCTID,
	Product,
	PRICE,
	AVG(PRICE) OVER() AVGPRICE
FROM SALES.PRODUCTS)t
where PRICE > AVGPRICE
	
SELECT * 
	FROM SALES.PRODUCTS
	 -- Subquery--
	 /* Result types,  Dependence type, Location type*/
	-- Result type
	-- Scalar subquery, Row subquery, Table subquery
	-- Scalar subquery gives a single value  eg (query with an aggregate function )
	 
 SELECT 
	PRODUCTID,
	Product,
	PRICE,
	(SELECT COUNT(*) FROM SALES.ORDERS) AS TOTALODERS  --> Subquery (Scalar type)
FROM sales.PRODUCTS
   --Row subquery gives a single column and multiple rows eg
SELECT 
	PRODUCTID
	from
	(SELECT ProductID FROM SALES.ORDERS) AS TOTALODERS  --> Subquery (Row type)
where ProductID = 101;

  -- Table Subquery gives multiple column and rows 

SELECT 
	*
	from
	(SELECT * FROM SALES.Orders) AS TOTALODERS  --> Subquery (Table type)
where ProductID = 101;
				-- OR
			-- find the products that have a price higher than the
	--average price of all products
SELECT
	*
	FROM	
(SELECT 
	PRODUCTID,
	Product,
	PRICE,
	AVG(PRICE) OVER() AVGPRICE
FROM SALES.PRODUCTS)t
where PRICE > AVGPRICE
	

				-- Location type
		-- Select, From,Join, where type
-- SELECT (Query after select ) eg
		--Show the productID,Product_Names, prices and total number of orders
	Select ProductID,
			PRODUCT,
			Price,
			(select count(*) from sales.Orders) as Total_Orders -- SELECT type only support Scalar Subquery (uses Aggregate function )
	from sales.products;

-- FROM (Query after From)
		-- find the products that have a price higher than the
	--average price of all products
SELECT
	*
	FROM	
(SELECT 
	PRODUCTID,
	Product,
	PRICE,
	AVG(PRICE) OVER() AVGPRICE
FROM SALES.PRODUCTS)t
where PRICE > AVGPRICE
	

	--JOIN subQuery (Using join to Main Query and Subquery) eg 
	--Show all the customers details and find the total order by customers 
Select SC.*,t.total_orders from sales.Customers as SC 
	left  join 
	(select customerID,
		count(*) total_orders from Sales.Orders group by CustomerID)t
		on SC.customerID = t.CustomerID

		--WHERE subQUERY (Query after where )
		--Syntax 
	/* Select * from Database.table where column =,>,<,>=,<=, != (select aggregate function() from Database.table)
	   Select * from Database.table where column IN, NOT IN, ANY,ALL,EXISTS (select aggregate function() from Database.table)
		*/
		-- Show details of the orders made by customers from germany 
 select * from sales.customers where Country = 'germany'
 select * from sales.orders where CustomerID IN ( select CustomerID from sales.customers where Country = 'germany')
 -- Find the female employees whose salaries are greater than the salaries of the male employees
 
 Select * from sales.Employees where Gender = 'F' and Salary > Any (Select Salary from sales.employees where Gender = 'M')
 -- 
 Select * from sales.Employees where Gender = 'M' and Salary > ALL (Select Salary from sales.employees where Gender = 'F')

 Select * from sales.Employees where Gender = 'F' 
 Select * from sales.Employees where Gender = 'M' 

 -- Dependency type
 -- Correclated and Non-correclated subquery
 --corrected subquery (subquery are dependent on main-query) eg using Logical operator Exists
 --eg
 Select 
	o.orderID,
	o.sales,
from sales.orders o
where exists(select 1 from sales.customers c where c.customerID = o.customerID and country = 'USA')


 --Non-correclated subquery, subquery do not depend on main-query

  --CTE--- Common Table Expression
  --Types
  --Recursive and Non- Recursive
  --Non Recursive(Independent of the Main_ query and run once without any repetions)eg Standalone CTE and Nested CTE
   --Standalone CTE
   --eg Find the total sales per customers
   -- Find the lasst orderDate for each customer
   -- Rank the customers based total sales per customer
   -- Segment Customer based on total sales
with CTE_Table as (
  select 
		CustomerID,
		sum(Sales) Total_sales       --- Standalone CTE & Multiple Standalones
    from sales.orders
   group by customerID),

CTE_Last_orderdate as(
   select 
	   CustomerID,
	   max(orderdate) LastOrder 
	from sales.orders
	group by CustomerID)

,CTE_RANKCUSTOMER AS(
  Select 
	customerID,
	Rank() over(order by Total_sales DESC) Rank_totalsales    -- Nested CTE (Refering to the first CTE )
  from CTE_Table)
  
,CTE_Segment as (
  select 
	CustomerID, 
	Case
		When Total_sales > 100 then 'High'        -- Nested CTE
		Else 'Low'
	End Segment
	from CTE_Table)

-- Main Query
  select 
	c.CustomerID,
	c.FirstName+' '+c.LastName as FullName,
	cte.Total_sales,
	cte_o.LastOrder,
	cRank.Rank_totalsales,
	cs.Segment
   from sales.Customers c 
   left join CTE_Table cte
   on c.CustomerID = cte.CustomerID
    left join
   CTE_Last_orderdate cte_o
   on c.customerID = cte_o.customerID
   left join CTE_RANKCUSTOMER cRank on
   c.customerID = cRank.CustomerID left join
   CTE_Segment cs on c.customerID = cs.customerID
    --eg eg  Find the running total of sales of each month
	with CTE_RunningTotal as (
  Select 
	datetrunc(month, OrderDate) Month, 
	sum(sales) Sales,
	Count(OrderDate) CountMonth                   -- Standalone CTE
  from sales.orders
  group by datetrunc(month, OrderDate))
 select 
	*, 
	sum(Sales)  over(order by Month) Running_Total
  from CTE_RunningTotal


   --Recursive CTE (Loop, self-referencig query that repeated processing data Until specific condition is met)
   --Eg Write a sequence from 1 to 20

with CTE_Table as (
	 select 
		 1 As Mynumber
		 union all
	 
	 select 
		Mynumber + 1 
	 from CTE_Table
	 where Mynumber <  20)

	Select 
		* 
	from CTE_Table

-- eg Show the Employee Hierarchy by displaying each employee's level within the organisation
With CTE_Hierarchy as (
-- Anchor CTE
select 
	EmployeeID,
	FirstName+' '+ LastName as FullName,
	ManagerID,
	1 as Level
	from sales.Employees 
	where  managerID is Null
	union all
	--Recursive Query
Select
	  e.EmployeeID,
	  e.FirstName+' '+LastName as FullName,
	  e.ManagerID,
	  Level + 1
	 from sales.Employees e 
	 inner join CTE_Hierarchy ctH
	 on e.ManagerID = ctH.employeeID)
	 --Main Query
 select * from CTE_Hierarchy 
   

     -- VIEWS (VIrtual Table)
--Syntax 
/* create view viewname as ( select 
  from TableName)
  eg  Find the running total of sales of each month
  */
Create View CTE_RunningTotal as (
  Select 
	datetrunc(month, OrderDate) Month, 
	sum(sales) Sales,
	Count(OrderDate) CountMonth
  from sales.orders
  group by datetrunc(month, OrderDate))
 select 
	*, 
	sum(Sales)  over(order by Month) Running_Total
  from CTE_RunningTotal

--eg Provide view that combines details from Orders, Product, Customer, Employee 
if Object_ID ('CustomerDetails', 'V') is not null
     drop view CustomerDetails
	 go
Create View CustomerDetails as(
 select 
	  o.CustomerID,
	  coalesce(c.FirstName,'')+''+ coalesce(c.LastName,'') CustomerName,
	  o.Quantity,
	  o.Sales,
	  coalesce(e.FirstName,'')+' '+ coalesce(e.LastName,'') SalesPerson,
	  e.Department,
	  e.salary salaryOfSalesPerson,
	  p.PRODUCT,
	  p.Category,
	  c.Country
 from sales.orders o left join sales.customers c
 on c.CustomerID = o.CustomerID left join sales.Products p
 on o.ProductID = p.ProductID left join sales.Employees e
 on o.SalesPersonID = e.EmployeeID  left join sales.OrdersArchive oA
 on o.OrderID = oA.orderID)
 Go
select 
  *
  FROM CustomerDetails
  where country != 'USA'

  select * from sales.Customers
  select* from sales.OrdersArchive
  --eg Provide a view for EU State Team that combines details from all tables and exclude data related to theUSA 
  
  Create View CustomerDetails_EU as(
 select 
	  o.CustomerID,
	  coalesce(c.FirstName,'')+''+ coalesce(c.LastName,'') CustomerName,
	  o.Quantity,
	  o.Sales,
	  coalesce(e.FirstName,'')+' '+ coalesce(e.LastName,'') SalesPerson,
	  e.Department,
	  e.salary salaryOfSalesPerson,
	  p.PRODUCT,
	  p.Category,
	  c.Country
 from sales.orders o left join sales.customers c
 on c.CustomerID = o.CustomerID left join sales.Products p
 on o.ProductID = p.ProductID left join sales.Employees e
 on o.SalesPersonID = e.EmployeeID  left join sales.OrdersArchive oA
 on o.OrderID = oA.orderID
 where c.Country != 'USA')

 Select * from CustomerDetails_EU

     --- TABLE (is the collection of data into rows and column)
	 --- Table Types 
	 -- Permanent and Temporary Table
--- Permanent Table: Create-Insert Table and CTAS Table 
-- Create-Insert Table (Conventional Table)
-- Eg 
Create Table Islamiyah (
	CustomerID int Identity(1,1),
	FullName Varchar(50),
	Department varchar(50),
	Salary Int)
	Insert into Islamiyah(Fullname,Department,Salary)
	Values('Ismaila Lukman','Marketing', 55000),
	      ('Raji Moshood','Technology', 1000000),
		  ('Lawal Aisha','Public Health', 120000)

		  --CTAS (Create Table as Select) TAble created from a query
 Select 
 CustomerID,
 sum(Sales) over(partition by CustomerID) TOtal_Sales,
 last_value(OrderDate)over(partition by CustomerID order by orderdate rows between current row and unbounded following)  lastOrderDate
 into CTAS_TABLE
 from sales.Orders

 -- Temporary Table (stored in the DB until the session end)
Select 
 CustomerID,
 sum(Sales) over(partition by CustomerID) TOtal_Sales,
 last_value(OrderDate)over(partition by CustomerID order by orderdate rows between current row and unbounded following)  lastOrderDate
 into #CTAS_TABLE
 from sales.Orders

 
	 