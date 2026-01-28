--Explore all the object in the Database

Select * from INFORMATION_SCHEMA.tables

--Explore all the columns in the Database

Select * from INFORMATION_SCHEMA.COLUMNS
where Table_name = 'dim_Customers'

Select * from INFORMATION_SCHEMA.COLUMNS
where Table_name = 'dim_products'

--Explore all the countries our customers come from.
Select * from gold.dim_customers
where country is null

Use DataWarehouse