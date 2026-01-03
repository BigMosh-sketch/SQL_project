--==========================================================================================================
--STORE PROCEDURE: Storing of queries to avoid repetition
--==========================================================================================================


	-- eg:For USA find the total number of customers and average score
Create procedure customerSummary as
Begin
Select 
	count(*) Totalcustomers,
	AVG(score) Avgscore
from sales.customers
where country = 'USA'
End
		--Execute store procedure
Exec customerSummary

--==========================================================================================================
--Make dynamic i.e add parameter to the stored procedure @procedurename datatype = 'defaultValue'
--==========================================================================================================

Alter procedure customerSummary @country Nvarchar(50) = 'USA' 
As
Begin															
Select 
	count(*) Totalcustomers,
	AVG(score) Avgscore
from sales.customers
where country = @country
End

--Execute Stored procedure
Exec customerSummary @country = 'Germany'

		---Multiple queries in stored procedure
--Find the total number of orders and total sales

Alter procedure customerSummary @country Nvarchar(50) = 'USA' 
As
Begin															
Select 
	count(*) Totalcustomers,
	AVG(score) Avgscore
from sales.customers
where country = @country

Select 
	count(*) Totalorders,
	Sum(sales) Totalsales
from sales.orders o inner join sales.customers c
on o.customerID = c.customerID
where c.country = @country

End

--==========================================================================================================
--Execute stored procedure
--==========================================================================================================

Exec customerSummary @country = 'Germany'
  
  --==========================================================================================================
		--Variables in stored procedure
		--==========================================================================================================

Alter procedure customerSummary @country Nvarchar(50) = 'USA' 
As
Begin

Declare @Totalcustomers Int ,@Avgscore Float;

Select 
	@Totalcustomers = count(*),
	@Avgscore = AVG(score),
	1/0
from sales.customers
where country = @country

Print 'Total customers from '+ @country + ':' + cast(@Totalcustomers as nvarchar);
Print 'Average score from ' +@country + ':' + cast(@Avgscore as nvarchar);

Select 
	count(*) Totalorders,
	Sum(sales) Totalsales
from sales.orders o inner join sales.customers c
on o.customerID = c.customerID
where c.country = @country

End

--==========================================================================================================
		--Execute stored procedure
--==========================================================================================================

Exec customerSummary
Exec customerSummary @country = 'Germany'

--==========================================================================================================
		--Control Flow 
		--Note: Null value bad for aggregation
--==========================================================================================================

Alter procedure customerSummary @country Nvarchar(50) = 'USA' 
As
Begin

Declare @Totalcustomers Int ,@Avgscore Float;

IF Exists(select 1 from sales.customers where score is null and country = @country)
Begin
	Print('Null value has been update to 0 ') 
	update sales.Customers
	set score = 0
	where score is null
End

Else
Begin
Print('No null value')
End

Select 
	@Totalcustomers = count(*),
	@Avgscore = AVG(score) 
from sales.customers
where country = @country

Print 'Total customers from '+ @country + ':' + cast(@Totalcustomers as nvarchar);
Print 'Average score from ' +@country + ':' + cast(@Avgscore as nvarchar);

Select 
	count(*) Totalorders,
	Sum(sales) Totalsales
from sales.orders o inner join sales.customers c
on o.customerID = c.customerID
where c.country = @country

End

--==========================================================================================================
-- Execute stored procedure
--==========================================================================================================

Exec customerSummary
Exec customerSummary @ country = Germany



Create table sales.Zainab (
Syn Int identity(1,1) primary key clustered,
FullName varchar(50) not null,
Age Int,
Categories varchar not null
)

Alter Table sales.zainab
Alter column Categories varchar (50) not null


Insert into sales.Zainab (Fullname,Age, Categories)
values('Aisha Abdulakeem', 12, 'Students'),
		('Kenny Haruna', 30, 'Business')

select * from sales.zainab
		Insert into sales.Zainab (Fullname, Categories)
		values('Zainab Haruna','Fashion Designer')

select count(age) as Totalcount, sum(age) TotalAge,Avg(age) AvgAge from sales.zainab
Select * from sales.zainab

--============================================================================================================
		--Execute stored procedure
--===========================================================================================================

Exec customerSummary
Exec customerSummary @country = 'Germany'

--==============================================================================================================
		--Control Flow 
		--Note: Null value bad for aggregation
--==========================================================================================================

Alter procedure customerSummary @country Nvarchar(50) = 'USA' 
As
Begin
Declare @Totalcustomers Int ,@Avgscore Float;

IF Exists(select 1 from sales.customers where score is null and country = @country)
Begin
	Print('Null value has been update to 0 ') 
	update sales.Customers
	set score = 0
	where score is null
End

Else
Begin
Print('No null value')
End

Select 
	@Totalcustomers = count(*),
	@Avgscore = AVG(score) 
from sales.customers
where country = @country

Print 'Total customers from '+ @country + ':' + cast(@Totalcustomers as nvarchar);
Print 'Average score from ' +@country + ':' + cast(@Avgscore as nvarchar);

Select 
	count(*) Totalorders,
	Sum(sales) Totalsales
from sales.orders o inner join sales.customers c
on o.customerID = c.customerID
where c.country = @country

End


-- Error Handling (Try/Catch)
Alter procedure customerSummary @country Nvarchar(50) = 'USA' 
As
Begin
	Begin Try
		Declare @Totalcustomers Int ,@Avgscore Float;

		--==============================
		-- Prepare and Cleanup
		--==============================

		IF Exists(select 1 from sales.customers where score is null and country = @country)
		Begin
			Print('Null value has been update to 0 ') 
			update sales.Customers
			set score = 0
			where score is null
		End

		Else
		Begin
			Print('No null value')
		End

		--==============================
		-- Generating Report
		--==============================
		--Calculate total number of customers and average score of a specific country

		Select 
			@Totalcustomers = count(*),
			@Avgscore = AVG(score)
		from sales.customers
		where country = @country

		Print 'Total customers from '+ @country + ':' + cast(@Totalcustomers as nvarchar);
		Print 'Average score from ' +@country + ':' + cast(@Avgscore as nvarchar);

		---Calculate Total number of orders and total sales of a specific country
		Select 
			count(*) Totalorders,
			Sum(sales) Totalsales,
			1/0
		from sales.orders o inner join sales.customers c
		on o.customerID = c.customerID
		where c.country = @country
	End Try

	Begin Catch

	--Error Handling

		Print('An error occured.')
		Print('Error message: ' + Error_message())
		Print('Error number: ' + cast(Error_number() as Nvarchar))
		Print('Error Line: ' + cast(Error_Line() as Nvarchar))
		Print('Error procedure: '+ Error_procedure())
	End Catch

End

-- Execute Stored procedure
Exec customerSummary
Exec customerSummary @country = 'Germany'



--- ==========================================================================================================
  --Triggers
--==================================================
 -- Triggers is stored procedure that runs automatically when a specific event is initiated (or done)
-- e.g  After any insert into sales.employee table , the sales.employeeLogs should be fill automatically

Create table sales.employeeLogs (
LogID Int identity(1,1),
EmployeeID Int,
LogMessage varchar(50),
LogDate date)

Create Trigger trgafterinsertemployees On sales.Employees
After Insert
As
Begin
Insert Into sales.employeeLogs(EmployeeID,LogMessage,LogDate)
Select 
	EmployeeID,
	'Added Employee with ID ='+ cast(EmployeeID as nvarchar),
	Getdate()
from inserted
End

--Try out
 Select * From Sales.Employees
 Insert Into Sales.Employees(EmployeeID,FirstName, LastName,Department)
 Values(6,'Ismaila','Ronke','Admin'),
		(7,'Bolaji','Zainab','Fashion Designer')

Select 
	* 
From sales.employeeLogs