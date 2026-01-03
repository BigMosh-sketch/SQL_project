-- Effective optimization of SQL Queries
		-- Tip 1: Select only what you need

--Bad practice: 
Select 
	* 
from sales.customers

--Good practice: 
Select 
	customerID,
	country 
from sales.customers

		--Tip 2: Avoid unneccessary Distinct and Order by


		-- Tip 3: For exploration purpose, limit rows
--Bad practice
Select 
	orderID,
	Sales
from sales.orders

--Good practice
Select Top 10
	orderID,					
	Sales
from sales.orders

			--Tip 4: Create a nonclustered index for frequently used column in where clause
--Bad practice
Select * from sales.orders where orderStatus = 'Delivered'

--Good pratice
Create nonclustered index idx_orders_orderstatus on sales.orders (orderstatus)
Select * from sales.orders where orderStatus = 'Delivered'

			--Tip5 Avoid applying functions to columns in where clause
			--eg
--Bad practice
  Select 
	*
  from sales.orders 
  where lower(orderstatus) ='delivery'

--Good pratice
Select 
	*
  from sales.orders 
  where orderstatus ='delivery'

--Bad practice
Select 
	* 
from sales.customers
where substring(firstName,1,1) = 'A'

--Good pratice
Select 
	*
from sales.customers
where firstName like 'A%'

--Bad practice
Select 
	* 
from sales.orders
where year(orderdate) = 2025

--Good pratice
Select 
	*
from sales.orders
where orderdate between '2025-01-01' and '2025-12-31'

		--Tip 6: Avoid leading wildcard as they prevent index usage
--Bad practice
Select 
	* 
from sales.customers
where FirstName like '%An%'

--Good pratice
Select 
	* 
from sales.customers
where FirstName like 'An%'

		--Tip 7: Avoid using multiple OR Statment in query
--Bad practice:
Select 
	*
from sales.customers
where customerID = 1 OR customerID =2 OR customerID = 3

--Good practice
Select 
	*
from sales.customers
where customerID IN (1,2,3)

			--Understand the speed of joins and use of inner join when possible
--Best performance:
Inner Join

-- Slightly worst performance
Right join
Left join

--Worst performance
outer join

		--Tip 9: Use explicit joins (Ansi join) instead of implicit join (non-anis join)
--Bad practice
Select 
	o.orderID,
	c.customerID,
	o.sales  from sales.customers c,sales.orders o
	where c.customerID =o.customerID

--Good practice
Select 
	o.orderID,
	c.customerID,
	o.sales  from sales.customers c join sales.orders o
	on c.customerID =o.customerID

	--Tip 10: Make sure to use index for columns used in the ON clause

	Select 
	o.orderID,
	c.customerID,
	o.sales  from sales.customers c join sales.orders o
	on c.customerID/*(Index)*/ =o.customerID /*(Index)*/

	--Tip 11: Filtering before joinig (Big Table)
-- Filtering after joining
Select 
	c.customerID,
	o.orderID
from sales.customers c left join sales.orders
on c.customerID = o.orderID
where orderstatus = 'Delivered'

--Filtering during joining
Select 
	c.customerID,
	o.orderID
from sales.customers c left join sales.orders
on c.customerID = o.orderIDs
and orderstatus = 'Delivered'

--Filtering before joining 
select 
	c.firstName,
	o.orderID
from sales.customers c left join (select customerID,orderID from sales.orders where orderstatus = 'Delivered') o
on c.customerID = o.customerID


			--Tip 12: Aggregate before joining(Big Table)
-- Joining and grouping			
Select 
	c.customerID,
	c.firstname,
	count(o.orderID) orderCount
from sales.customers c inner join sales.orders o
on c.customerID = o.customerID
group by c.customerID, c.firstname


--Pre-aggregated subquery
Select 
	c.customerID,
	c.firstname,
	o.countOrder
from sales.customers c inner join (select customerID,count(orderID)  countOrder from sales.orders group by  customerID) o
on c.customerID = o.customerID

--correlated subquery

Select 
	customerID,
	firstname,
	(select count(orderID)  countOrder from sales.orders o where c.customerID = o.customerID) as orderCount
from sales.customers  c

-- Tip 13: Use union instead of OR in joins
--Bad practice
Select
	o.orderID,
	c.firstname
from sales.customers c inner join sales.orders o
on c.customerID = o.customerID
OR c.customerID =o.SalesPersonID

-- Good practice
Select
	o.orderID,
	c.firstname
from sales.customers c inner join sales.orders o
on c.customerID = o.customerID
 union
Select
	o.orderID,
	c.firstname
from sales.customers c inner join sales.orders o
on c.customerID = o.SalesPersonID

		---Tip 14: Check for nested loops and use SQL hints (Big Table recommend to  use option(Hash join))

Select
	o.orderID,
	c.firstname
from sales.customers c inner join sales.orders o
on c.customerID = o.customerID
option(Hash join)

		--Tip 15: Use union all instead of union | duplicate are acceptable

		--Tip 16: Use union all + Distinct instead of union | duplicates are not acceptable
--Bad practice
Select customerID from sales.orders
union
Select customerID from sales.OrdersArchive
--Good practice
Select Distinct CustomerID
from
(Select customerID from sales.orders
union all
Select customerID from sales.OrdersArchive)t

			--Tip 17: Use columnnstore index for Aggregation for large tables
Select
	customerID,
	count(orderID) as orderCount
from sales.orders
group by customerID

--Create clustered columnstore index idx_ordes_columnstore on sales.orders

	--Tip 18: Pre-aggregate data and store it in a new table for reporting

Select 
	Month(orderdate) as month,
	sum(sales) as totalSales
into sales.salesSummaryPerMonth
from sales.orders
group by Month(orderdate)

--Drop table sales.salesSummaryPerMonth


				---Best Practices for subquery

	--Tip 19: Join OR Exists OR IN
--JOIN (Good performance preferable for readability)
Select
	o.orderID,
	o.sales
from sales.orders o inner join sales.customers c
on c.customerID = o.customerID 
where c.country = 'USA'

--EXISTS (Good performance preferable for Big table)
Select 
	o.orderID,
	o.sales,
from sales.orders o
where exists(select 1 from sales.customers c where c.customerID = o.customerID and country = 'USA')

--IN (Bad performance)
Select
	 o.orderID,
	 o.sales
 from sales.orders o
 where o.CustomerID IN (select customerID from sales.customers where country = 'USA')

		--Tip 20: Avoid redundant logic in your query
--Bad performance
select
	EmployeeID,
	FirstName,
	'Above average' Status
from sales.Employees
where salary >(select avg(salary) from sales.Employees)
union 
select
	EmployeeID,
	FirstName,
	'Below average' Status
from sales.Employees
where salary < (select avg(salary) from sales.Employees)

--Good performance
select
	EmployeeID,
	FirstName,
Case
when salary > (select avg(salary) from sales.Employees) then 'Above Average'
when salary < (select avg(salary) from sales.Employees) then 'Below Average'
Else 'Average'
End as Status
from sales.Employees

		--Best practices for creating table
		--Tip 21:Avoid using unnecessary data type, Text and Varchar
		--Tip 22:Avoid unnecessary large lengths in data type
		--Tip 23:Use not null constraint where applicable
		--Tip 24: Ensure all your tables have a clustered primary key
		--Tip 25: create a nonclustered index for foreign keys that are used frequently
/*Create Table customerInfo (
	CustomerID Int primary key clustered,
	FirstName Varchar(50),
	LastName Varchar(50),
	country Varchar(50),
	TotalPurchase Float,
	Score Int,
	Birthdate Date,
	EmployeeID Int,
	Constraint FK_customersInfo_employeeID Foreign key (EmployeeID) reference sales.employees(employeeID)
		)
		Create nonclustered index idx_customerInfo_employeeID on sales.customerInfo(EmployeeID)*/

		--Best practices Indexing
		--Tip 26: Avoid over Indexing
		--Tip 27: Drop unused Indexes
		--Tip 28: Update statistics (weekly)
		--Tip 29:Reorganize and rebuild indexes (weekly)
		--Tip 30: Partition large tables to improve performances

	--Bonus
	--Ensure your query is clear
	-- Optimize performance only when is necessary
	--Always test using Execution plan




























