/*
	Script Note:
	1. Uploading from Bronze layer into Silver layer
	2. Create Silver.table for each CRM and ERP Table
	3. Truncate and Insert into Silver CRM and ERP Tables 
	4. Using Stored procedure 

*/

-- Explore & Understanding the data in the Bronze Layer										
Select Top 1000 * From bronze.crm_cust_info
Select Top 1000 * From bronze.crm_prd_info
Select Top 1000 * From bronze.crm_sales_details
Select Top 1000 * From bronze.erp_CUST_AZ12
Select Top 1000 * From bronze.erp_LOC_A101
Select Top 1000 * From bronze.erp_PX_CAT_G1V2

--- Check Duplicate--
Select 
	prd_key,
	row_number () Over( partition by prd_key order by prd_key) as row_number1
From bronze.crm_prd_info
Order by row_number () Over( partition by prd_key order by prd_key) DESC
 
		-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.. Create Silver layer Tables<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

								--->>>>>>>>>>>>>>>CRM<<<<<<<<_______


								----cust_info------

If object_ID ('silver.crm_cust_info', 'U') IS NOT NULL
	Drop Table silver.crm_cust_info
Create Table silver.crm_cust_info (
cst_id Int,
cst_key Nvarchar(50),
cst_firstname Nvarchar(50),
cst_lastname Nvarchar(50),
cst_marital_status Nvarchar(50),
cst_gndr Nvarchar (50),
cst_create_date Date,
dwh_create_date DateTime2 Default GetDate()
);
Go

											---Prd_Info--------
If Object_Id('silver.crm_prd_info','U') IS NOT NULL
	Drop Table silver.crm_prd_info;

Create Table silver.crm_prd_info(
prd_id Int,
cat_id Nvarchar(50),
prd_key Nvarchar(50),
prd_nm Nvarchar(50),
prd_cost Int,
prd_line Nvarchar (50),
prd_start_dt Date,
prd_end_dt Date,
dwh_create_date DateTime2 Default GetDate()
);
Go 



IF Object_ID ('Silver.crm_sales_details', 'U') Is Not Null
	Drop Table silver.crm_sales_details;

Create Table silver.crm_sales_details(
sls_ord_num Nvarchar(50), 
sls_prd_key  Nvarchar(50),
sls_cust_id Int,
sls_order_dt Date,
sls_ship_dt Date,
sls_due_dt Date,
sls_sales Int,
sls_quantity Int,
sls_price Int,
dwh_create_date DateTime2 Default GetDate()
);

Go

   --------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>ERP<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<____________________________

										--------CUST_AZ12-----------

   If Object_Id('silver.erp_CUST_AZ12','U') IS NOT NULL
	Drop Table silver.erp_CUST_AZ12;

Create Table silver.erp_CUST_AZ12(
CID Nvarchar(50),
BDATE Date,
GEN Nvarchar (50),
dwh_create_date DateTime2 Default GetDate()
);
Go


									--------LOC_A101-----------

If Object_Id('silver.erp_LOC_A101','U') IS NOT NULL
	Drop Table silver.erp_LOC_A101;

Create Table silver.erp_LOC_A101(
CID Nvarchar(50),
CNTRY Nvarchar(50),
dwh_create_date DateTime2 Default GetDate()
)
Go

							

							--------PX_CAT_G1V2-----------
If Object_Id('silver.erp_PX_CAT_G1V2','U') IS NOT NULL
	Drop Table silver.erp_PX_CAT_G1V2;

Create Table silver.erp_PX_CAT_G1V2(
ID Nvarchar(50),
CAT Nvarchar(50),
SUBCAT Nvarchar(50),
MAINTENANCE Nvarchar(50),
dwh_create_date DateTime2 Default GetDate()
);


--=======================================================================================================================================================================

----------------------------> Upload to Silver layer <-------------------------------------------

----=====================================================================================================================================================================
								
Create Or Alter procedure silver.load_silver
As 
Begin
Declare @Set_start_time DateTime, @Set_End_time DateTime, @Batch_start_time DateTime, @Batch_end_time DateTime;

  set @Batch_Start_time = GetDate();
	Begin Try
			
						Print'-------==========================================================================================='
						Print'--------->>>>>>>>>>>>>>>>>>>> Uploading into Silver<<<<<<<<<<<<<<<<<<<<<<<------------------------'
						Print'-------==========================================================================================='
								---Cust_Info-----
										--Loading into silver.crm_cust_info--
		set @Set_start_time = GetDate();
									
									Print'------>>>>>>>>>Truncating Table: Silver.crm_cust_info <<<<<<<----------------'	
		Truncate Table silver.crm_cust_info

									Print'------>>>>>>>>>Inserting into Table: Silver.crm_cust_info <<<<<<<----------------'
		Insert into silver.crm_cust_info(cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)

		Select 
			cst_id,
			cst_key,
			trim(cst_firstname) as cst_firstname,             -- Remove unwanted space
			trim(cst_lastname) as cst_lastname,
			Case
				When upper(trim(cst_marital_status)) = 'M' Then 'Married'
				When upper(trim(cst_marital_status)) = 'S' Then 'Single'          -- Normalize the marital status to readable format
				Else 'N/A'
			End as cst_marital_status,
			Case
				When upper(trim(cst_gndr)) = 'M' Then 'Male'
				When upper(trim(cst_gndr)) = 'F' Then 'Female'                  --- Normalize the gender to readable format
				Else 'N/A'
			End as cst_gndr,
			cst_create_date
		From( 
		Select 
			*,
			row_number() Over (partition by cst_id Order by cst_create_date Desc) as row_number              
		from bronze.crm_cust_info
		Where cst_id Is Not Null)t
		Where row_number = 1                                                  -- select the most recent record

		Set @Set_End_time =GetDate();

		Print'Time duration for crm_cust_info: ' + cast(Datediff(second,@set_start_time,@set_end_time) as Nvarchar) + ' Seconds';



									---Prd_Info-----
								--Loading into silver.crm_prd_info--

							
			set @Set_start_time = GetDate();			
							
							Print'----->>>>>>>>>>> Truncating Table: Silver.crm_prd_info<<<<<<<<<<<<<<----------------------'
		Truncate Table silver.crm_prd_info

							Print'----->>>>>>>>>>> Inserting into Table: Silver.crm_prd_info<<<<<<<<<<<<<<----------------------'
		Insert into silver.crm_prd_info(prd_id,cat_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt)

		select 
			prd_id,
			Replace(substring(prd_key,1,5),'-','_') as cat_id,
			substring(prd_key,7,len(prd_key)) as prd_key,
			prd_nm,
			IsNull(prd_cost,0) as prd_cost,
			Case
			 When  upper(trim(prd_line)) = 'M' Then 'Mountainn'
			 When upper(trim(prd_line)) = 'R' Then 'Road'
			 When  upper(trim(prd_line)) = 'S' Then 'Other Sales'
			 When  upper(trim(prd_line)) = 'T' Then 'Touring'
			 Else 'N/A'
			 End as prd_line,
			cast(prd_start_dt as Date) as prd_start_dt,
			cast(lead(prd_start_dt ) Over(partition by prd_key order by prd_start_dt)  -1 as Date) as prd_end_dt
		from bronze.crm_prd_info


		 set @Set_end_time = GetDate();
		 Print'Time duration for crm_prd_info: ' + cast(Datediff(second,@set_start_time,@set_end_time) as Nvarchar) + ' seconds'




					---- CRM_sales_order

					set @Set_start_time = GetDate();
					Print'----->>>>>>>>>>> Truncating Table: Silver.crm_sales_details<<<<<<<<<<<<<<----------------------'	

		Truncate Table silver.crm_sales_details

					Print'----->>>>>>>>>>> Inserting into Table: Silver.crm_sales_details<<<<<<<<<<<<<<----------------------'	

		Insert into silver.crm_sales_details(sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price)
		Select 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			Case 
			When sls_order_dt <= 0 or len(sls_order_dt) != 8  Then Null
			Else Cast(Cast(sls_order_dt as Nvarchar) as Date)
			End as sls_order_dt,
			Cast(Cast(sls_ship_dt as Nvarchar) as Date) as sls_ship_dt,
			Cast(Cast(sls_due_dt as Nvarchar) as Date) as sls_due_dt,
			Case
			When sls_sales != sls_quantity*sls_price or sls_sales <= 0 or sls_sales is null Then abs(sls_quantity*sls_price)
			Else sls_sales
			End as sls_sales,
			sls_quantity,
			Case
			When sls_price Is Null Then abs(sls_sales)/sls_quantity
			Else abs(sls_price)
			End as sls_price
		from bronze.crm_sales_details


		set @Set_end_time = GetDate();
		Print'Time duration for crm_sales_details: ' + cast(Datediff(second,@set_start_time,@set_end_time) as Nvarchar)+ ' seconds'

	

		-------------------------------------------------------------ERP<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	

												----->>>>>ERP_CUST_AZ12<<<<<<----------------
						set @Set_start_time = GetDate();

						Print'----->>>>>>>>>>> Truncating Silver.erp_cust_az12<<<<<<<<<<<<<<----------------------'	
	
									------ Truncate & Insert into ERP_CUST_AZ12-----------------------

						Print'----->>>>>>>>>>> Inserting into Silver.erp_cust_az12<<<<<<<<<<<<<<----------------------'

		Truncate Table silver.erp_CUST_AZ12

		Insert Into silver.erp_CUST_AZ12(CID,BDATE,GEN)

		Select
			substring(CID,4,len(CID)) as CID,
			BDATE,
			Case
				When trim(GEN) in ('F','Female') then 'Female'
				When trim(GEN) in ('M','Male') then 'Male'
				Else 'N/A'
			End as GEN
		From bronze.erp_CUST_AZ12

		set @Set_end_time = GetDate();
		Print'Time duration for erp_cust_az12:' + cast(Datediff(second,@set_start_time,@set_end_time) as Nvarchar)+ ' seconds'
	

						----------------------ERP_LOC_A101-----------------------

						set @Set_start_time = GetDate();

							Print'----->>>>>>>>>>> Truncating Table: Silver.erp_loc_a101<<<<<<<<<<<<<<----------------------'	
															--- Truncate Table-----
		Truncate Table silver.erp_LOC_A101
												
							Print'----->>>>>>>>>>> Inserting into Table: Silver.erp_loc_a101<<<<<<<<<<<<<<----------------------'
														--- Upload into Silver.erp_LOC_A101---------
		Insert Into silver.erp_LOC_A101(CID,CNTRY)
		Select 
			Replace(CID,'-','') as CID,
			Case
				When trim(CNTRY) In ('US','USA') Then 'United States'
				When trim(CNTRY) In ('DE') Then 'Germany'
				When trim(CNTRY) is Null or trim(CNTRY) = '' Then 'N/A'
				Else trim(CNTRY)
			End as CNTRY
		From bronze.erp_LOC_A101

		set @Set_end_time = GetDate();
		Print'Time duration for erp_loc_a101:' + cast(Datediff(second,@set_start_time,@set_end_time) as Nvarchar)+ ' seconds'



					------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SILVER.ERP_PX_CAT_G1V2<<<<<<<<<<<<<<<<<<<---------------------------

				set @Set_start_time = GetDate();
					Print'----->>>>>>>>>>> Truncating Table: Silver.erp_px_cat_g1v2<<<<<<<<<<<<<<----------------------'

		Truncate Table Silver.erp_PX_CAT_G1V2 

					Print'----->>>>>>>>>>> Inserting into Table: Silver.erp_px_cat_g1v2<<<<<<<<<<<<<<----------------------'

		Insert Into silver.erp_PX_CAT_G1V2(ID,CAT,SUBCAT,MAINTENANCE)
		Select
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
		From bronze.erp_PX_CAT_G1V2

		set @Set_end_time = GetDate();
		Print'Time duration for erp_px_cat_g1v2:' + cast(Datediff(second,@set_start_time,@set_end_time) as Nvarchar)+ ' seconds'
	End Try
	Begin Catch
		Print'Error Message'+ Error_message()
		Print 'Error Number'+ cast(Error_number() as Nvarchar)
		Print 'Error State' + cast(Error_state() as Nvarchar)
	End Catch
	set @Batch_end_time = GetDate();

	Print'Duration for Procedure :' + cast(Datediff(second,@Batch_start_time,@Batch_end_time) as Nvarchar)+ ' seconds'
End


------->>>>>>Run the Procedure<<<<<<<<<<<<<<<---------
 Exec silver.load_silver




