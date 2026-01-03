-- Indexes(Data structure that provide quick access to data and optimise the speed of the query)
-- Structure type, Storage and Function Index
   --Structure Index, Clustered Index and Non-clustered index
     --Clustered Index (one Column and Unique key(Primary))
     -- Clustered Index Syntax
     -- Create Clustered Index Idx_Tablename_columnname on Tablename
     --Note CLustered Index can only be created once on a table and preferable a unique column
Select 
    *  
    into dbo.customers
    from sales.customers
Create Clustered Index idx_dbocustomers_customerID on dbo.customers (CustomerID)
Drop Index idx_dbocustomers_customerID on dbo.customers
Create clustered index idx_dbocustomers_FirstName on dbo.customers(firstName)
Drop Index idx_dbocustomers_FirstName on dbo.customers

 insert into dbo.customers(CustomerID,FirstName,Lastname,Country,Score)
 Values(6,'Anna','Ismai','Jamaica',200)
 Delete dbo.customers
 where customerID =6
Select * from sales.customers where customerID = 2
Use salesDB

--Non-clustered Index (Multiple in a table)
select * from sales.customers
Create Nonclustered Index idx_dbocustomers_FirstName on dbo.customers(FIrstName)
Create Nonclustered Index idx_dbocustomers_LastName on dbo.customers(LastName)
Drop Index idx_dbocustomers_LastName on dbo.customers
Drop Index idx_dbocustomers_FirstName on dbo.customers
 -- Non-Clustered Index (Composite i.e more one column)
 Create Nonclustered Index idx_dbocustomers_FirstName_LastName on dbo.customers(FIrstName,LastName)
 Drop Index idx_dbocustomers_FirstName_LastName  on dbo.customers
select * from dbo.customers
where FirstName = 'Anna' and Lastname = 'Adams'

  -- Storage Index
   -- Rowstore Index and Columnstore Index
   --Note by Default, Indexes are Rowstore Index eg, all the examples made above
   --RowStore Index
   -- eg Example above


   -- Columnstore Index
   Create clustered columnstore Index idx_dbocustomers_customerID on dbo.customers
    Create nonclustered columnstore Index idx_dbocustomers_customerID on dbo.customers(FirstName,LastName)

    -- Function, Unique Index and Filter Index
      --Unique Index (Column must be of unique values)
 Create unique nonclustered index idx_dbocustomers_FirstName on dbo.customers (FirstName)
      Drop Index idx_dbocustomers_LastName on dbo.customers 
Create unique nonclustered index idx_dbocustomers_LastName on dbo.customers (LastName)
Insert into
        --Filter Index
  Create nonclustered index idx_dbocustomers_irst on dbo.customers (FirstName)
  where firstname = 'Anna'
  Drop Index idx_dbocustomers_first on dbo.customers

  select * from dbo.customers
  where firstname = 'Anna'


  --Syntax to view the indexes in a specific Table 
  Use SalesDB
  sp_helpindex 'dbo.customers'

  Select * from sys.indexes
  Select * from sys.tables
  
  Select * from sys.dm_db_index_usage_stats

  
Select  
      tbl.name as tableName,
      idx.type_desc as indexType,
      idx.is_primary_key as isPrimaryKey,
      idx.is_unique as isUnique,
      idx.is_disabled as isDisabled,
      sts.user_seeks as userSeeks,
      sts.user_scans as userScans,
      sts.user_lookups as userLookups,
      sts.user_updates as userUpdates,
      sts.last_user_seek as lastUserSeek,
      sts.last_user_scan as lastUserScan
from sys.indexes idx JOIN sys.tables tbl
on idx.object_id = tbl.object_id left join sys.dm_db_index_usage_stats sts
on idx.object_id = sts.database_id 

        --- Indexes recommendation
select * from sys.dm_db_missing_index_details
select * from sys.columns
select * from sys.index_columns

-- Execution Plan, shows how the database execute queries
use SalesDB
-- comparing the querie with indexes and without
/* 
 select
	*                                                          Create a duplicate
into dbo.factresellersales_HP
from dbo.factresellersales
                      --  WITH INDEXES
select * from dbo.factresellersales
where carrierTrackingNumber = '4911-403C-98'
 
 Create nonclustered index idx_dbofactResellerSales_carrierTrackingNumber on dbo.factresellersales ( carrierTrackingNumber)*/

                          --WITHOUT INDEXES
/*select * from dbo.factresellersales_HP
where carrierTrackingNumber = '4911-403C-98'*/

            --NOTICE
/* 1. QUERIES with indexes excute fast than without
 2. columnstore index execute fast than rowstore index
 3. Avoid over indexes in your table confuses the queries on which to use

            ---EXECUTION PLAN HINTS (can make the queries run while using a specific execution plan)*/
/*select * from dbo.factresellersales_HP  with(forceseek) or with(index (PK_FactResellerSales_SalesOrderNumber_SalesOrderLineNumber))
join 
where carrierTrackingNumber = '4911-403C-98'
option(hash join)*/

            --- SQL PARTITIONING: techniques of dividing Big Table into partitions
--STEP1 create a partition function(Logic on how to divide data into partitions based on partition key like column e.g Region,Country,Date)

Create partition function partitionByYear (Date) as range left for values ('2023-12-31','2024-12-31','2025-12-31','2026-12-31')

    -- List of all partition function that exists (check)
select 
    * 
from sys.partition_functions

-- Step 2 Create File Group (Logical container that one or more data files)
Alter Database SalesDB add Filegroup FG_2023;

Alter Database SalesDB add Filegroup FG_2024;

Alter Database SalesDB add Filegroup FG_2025;

Alter Database SalesDB add Filegroup FG_2026;

Alter Database SalesDB add Filegroup FG_2027;




-- Query to check file group that exists in the database 
Select 
    * 
from sys.filegroups

-- Step 3 Add .ndf files to each filegroup
Alter Database salesDB add file 
(
    Name = P_2023,   --Logic name
    Filename ='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2023.ndf'
) to filegroup FG_2023

Alter Database salesDB add file 
(
    Name = P_2024,   --Logic name
    Filename ='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2024.ndf'
) to filegroup FG_2024

Alter Database salesDB add file 
(
    Name = P_2025,   --Logic name
    Filename ='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2025.ndf'
) to filegroup FG_2025

Alter Database salesDB add file 
(
    Name = P_2026,   --Logic name
    Filename ='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2026.ndf' -- Physical name
) to filegroup FG_2026;

Alter Database salesDB add file 
(
    Name = P_2027,   --Logic name
    Filename ='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2027.ndf' -- Physical name
) to filegroup FG_2027;

--Query to check file in the filegroup
select 
    fg.Name as fileGroupName,
    mf.name as fileName,
    mf.physical_name as physicalName,
    mf.size/128 as fileSize,
    mf.database_id as databaseId
from sys.filegroups fg join sys.master_files mf 
on fg.data_space_id = mf.data_space_id
where mf.database_id = 6

--Step 4  Create  a partition scheme(Serve as a link between partition function and filegroup)
Create partition scheme schemePartitionByYear as partition partitionByYear to (FG_2023,FG_2024,FG_2025,FG_2026,FG_2027)


-- Check if the scheme as linked the partition to filegroup
select  
    fg.name as fileGroupName,
    mf.name as fileName,
    mf.Physical_name as phyiscalName,
    mf.size/128 as sizeInMB,
    mf.data_space_id,
    ps.name as partitionSchemeName,
    pf.name as partitionFunctionName,
    ds.partition_scheme_id
from sys.filegroups fg join sys.master_files mf
on fg.data_space_id = mf.data_space_id  join sys.destination_data_spaces ds
on fg.data_space_id = ds.data_space_id join sys.partition_schemes ps
on ds.partition_scheme_id = ps.data_space_id join sys.partition_functions pf
on ps.function_id = pf.function_id

--Step 5 Create a partition Table
Create table sales.order_partitioned
    (
        OrderID int,
        orderDate date,
        sales int
    ) on schemePartitionByYear(orderDate)

--Step 6 Insert into table
Insert into sales.order_partitioned(OrderID,orderDate,sales)
    values(1,'2025-12-21',123)

Insert into sales.order_partitioned(OrderID,orderDate,sales)
    values(1,'2027-12-11',123)

insert into sales.order_partitioned(OrderID,orderDate,sales)
    values(1,'2025-12-01',123)

insert into sales.order_partitioned(OrderID,orderDate,sales)
    values(1,'2026-12-31',123)


select
    * 
from sales.order_partitioned

        -- Check  values in the partitions
select 
    fg.name,
     p.partition_number as partionNumber,
     p.rows as numberOfRows
from sys.partitions p join sys.destination_data_spaces ds
on p.partition_number = ds.destination_id join sys.filegroups fg
on ds.data_space_id = fg.data_space_id
where object_name(p.object_id) = 'order_partitioned'

select
* from sys.partitions

select
* from sys.destination_data_spaces
select
* from sys.filegroups