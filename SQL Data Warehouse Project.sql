--- ETL(Extraction, Transform and Load)

----> Sources(one or more) --> ETL --> DataWarehouse -----> Generating report from the data(data Analyst)
----------------------------------------------------		----------------------------------------
							-- Data Engineer                       Data Analyst

					-- Component of ETL
					--Extraction 
							--Extraction Method---> Pull or Push Extraction Method
							--Extraction type ---> Full or  Incremental Extraction Type
							--Extraction techniques --> Manual extractions, Web scraping, Change Data Capture (CDC), Database querying, File Parsing, API Calls, Event Based Streaming



					-- Transformation
							--Data Enrichment, Data Norminization and Standardization, 
							--Column Derived, Data Integration, Business Rules and Logic,
							-- Data aggregation, Data Cleaning(Remove Duplicate, Outlier Detecting, Handling unwanted space, 
							--Handling invalid values,Handling Missing data,Data Filtering, Data type casting)


					-- Loading
							--Processing Type --> Batch or Stream processing
							--Load Method --> Full Load(Truncate & Insert or Upsert or Create,Insert,Drop), or Incremental Load(upsert, merge,Append)
							-- Slowly Changing Dimensions (SCD) --> SCD 0 No Historization or SCD 1 Overwrite or SCD 2 Historization or SCD
						
						--- Data Warehouse
						-- Bronze, Silver and Gold method
						-- Source System --> Bronze --> Silver --> Gold --> Ready to use
										 ------------ Data Warehouse ------

						-- Go to Notion Plan for more Info about the data Warehouse

						-- Bronze Layer
						--Important Question to ask before developing Bronze layer
						--Business Context & Ownership
								--1.Who owns the data i.e story behind the data, Who is responsible for the data
								--2.What Business processes it support
								--3. System and Data documentation
								 --4. Data Model for the source system and Data Catlog

						-- Architexture and Technology Stack
								--1. How is the source system storing the data (SQL Server,Oracle, AWS, Azure(online Cloud system))
								--2. What are the integration capabilities--> How to get the data eg.API,Kafka, File Extract, Direct DB)

						-- Extract & Load
							--1. Full or Incremental Load
							--2. Scope and Historization Needs
							-- 3. What is the expected size of the extract ?
							-- 4. Are there data volume limitations ?
							--5. How to avoid impacting the source system's performance ?
							-- Authentication and Authorization ( Password, SSH keys, VPN, IP whitelisting)


							-- Data Warehouse---

/* Scripts Note
 1.Create a Database for SQL Data Warehouse Project and Schemas for the Bronze, Silver and Gold Layer
 2. Create tables for for the  3 project each in the CRM and ERP Folder for the bronze layer 
 3. Using stored procedure to Upload  the data into the bronze  layer*/
							---Create the Bronze Layer

Create Database DataWarehouse

Create Schema Bronze
Go
Create Schema Silver
Go
Create Schema Gold

--- Create the Bronze Layer



Create Table bronze.crm_cust_info (
cst_id Int,
cst_key Nvarchar(50),
cst_firstname Nvarchar(50),
cst_lastname Nvarchar(50),
cst_marital_status Nvarchar(50),
cst_gndr Nvarchar (50),
cst_create_date Date
)
Go

Create Table bronze.crm_prd_info(
prd_id Int,
prd_key Nvarchar(50),
prd_nm Nvarchar(50),
prd_cost Int,
prd_line Nvarchar (50),
prd_start_dt DateTime,
prd_end_dt DateTime
)
Go 
IF Object_ID ('bronze.crm_sales_details', 'U') Is Not Null
	Drop Table bronze.crm_sales_details

Create Table bronze.crm_sales_details(
sls_ord_num Nvarchar(50), 
sls_prd_key  Nvarchar(50),
sls_cust_id Int,
sls_order_dt Int,
sls_ship_dt Int,
sls_due_dt Int,
sls_sales Int,
sls_quantity Int,
sls_price Int)

Go
Create Table bronze.erp_CUST_AZ12(
CID Nvarchar(50),
BDATE Date,
GEN Nvarchar (50))
Go
Create Table bronze.erp_LOC_A101(
CID Nvarchar(50),
CNTRY Nvarchar(50)
)
Go
Create Table bronze.erp_PX_CAT_G1V2(
ID Nvarchar(50),
CAT Nvarchar(50),
SUBCAT Nvarchar(50),
MAINTENANCE Nvarchar(50)
)

--Upload data into Bronze Table  (Trunctate & Insert)

						  -- Source_CRM
--						
Alter Procedure bronze.load_bronze As 
Begin
	Declare @Start_Time DateTime, @End_Time DateTime; 
	Begin Try
		Print '======================================='
		Print 'Loading Bronze Layer'
		Print '======================================='

										Print'>>>>>>>>>>CRM-TABLES<<<<<<<<<<<<<<<'

										--/Cust_Info/
										Print '>>>>CUST_INFO<<<<'
	 Set @Start_Time = GetDate();
		Truncate Table bronze.crm_cust_info 

		Bulk Insert bronze.crm_cust_info
		from 'C:\Users\USER\Documents\SQL Server Management Studio\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			Firstrow = 2,
			Fieldterminator = ',',
			Tablock
			)


								--/Prd_Info/

								PRINT '>>>>PRD_INFO<<<<'
		Truncate Table bronze.crm_prd_info

		Bulk Insert bronze.crm_prd_info
		From 'C:\Users\USER\Documents\SQL Server Management Studio\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			Firstrow = 2,
			Fieldterminator = ',',
			Tablock
			)




						--/Sales_Details/
						PRINT '>>>>SALES_DETAILS<<<<'
		Truncate Table bronze.crm_sales_details

		Bulk Insert bronze.crm_sales_details
		From 'C:\Users\USER\Documents\SQL Server Management Studio\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		With (
			Firstrow = 2,
			Fieldterminator = ',',
			Tablock
		)


										
										Print'>>>>>>>>>>>>>>>>SOURCE_ERP<<<<<<<<<<<<<<'
												--Source_ERP

												--/CUST_AZ12-
												PRINT'>>>>CUST_AZ12<<<<'

		Truncate Table bronze.erp_CUST_AZ12

		Bulk Insert bronze.erp_CUST_AZ12
		From 'C:\Users\USER\Documents\SQL Server Management Studio\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		With (
			Firstrow = 2,
			Fieldterminator = ',',
			Tablock
			)

									--/LOC_A101
									PRINT'>>>>LOC_A101<<<<'
			Truncate Table bronze.erp_LOC_A101

		Bulk Insert bronze.erp_LOC_A101
		From 'C:\Users\USER\Documents\SQL Server Management Studio\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		With (
			Firstrow = 2,
			Fieldterminator = ',',
			Tablock
			)

						 ---/PX_CAT_G1V2
						 PRINT '>>>>PX_CAT_G1V2<<<<'
		Truncate Table bronze.erp_PX_CAT_G1V2

		Bulk Insert bronze.erp_PX_CAT_G1V2
		From 'C:\Users\USER\Documents\SQL Server Management Studio\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		With (
			Firstrow = 2,
			Fieldterminator = ',',
			Tablock
			)
	End Try
	Begin Catch
	Print '============================================================='
	Print 'Error occured during the loading of  Bronze Layer'
	Print'Error Message' + Error_message()
	Print'Error Number' + Cast(Error_Number() as Nvarchar)
	Print'Error State' + Cast(Error_state() as Nvarchar)
	Print '============================================================='
	End Catch

	Set @End_Time = GetDate();
	Print'Duration of Loading:'+ cast(Datediff(second,@Start_Time,@End_Time) as Nvarchar)+ ' Seconds'
END

	
	--===========================================================
   --- Execute Stored procedure 
   
	--===========================================================

Exec bronze.load_bronze

	Select * from bronze.erp_CUST_AZ12
	Select * from bronze.erp_LOC_A101
	Select * from bronze.erp_PX_CAT_G1V2


	------ View the Schemas in the Database
SELECT name
FROM sys.schemas
