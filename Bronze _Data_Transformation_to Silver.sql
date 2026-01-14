use DataWarehouse

				--- Data Explore and Clean---
Select 
	* 
From bronze.crm_cust_info


									--Silver.crm_cust_info--
                                     --- Check Null or Duplicate in the primary key
 --Check for duplicate on primary key
Select 
	cst_key,
	count(*)
From bronze.crm_cust_info
Group by cst_key
Having count(*) > 1 AND cst_id is Null

-- Remove Duplicate and Null value from the primary key
Select 
	*
From( 
Select 
	*,
	row_number() Over (partition by cst_id Order by cst_create_date Desc) as row_number
from bronze.crm_cust_info
Where cst_id Is Not Null)t
Where row_number = 1 


-- Check unwanted space 

Select 
	cst_firstname
From silver.crm_cust_info
where cst_firstname != trim(cst_firstname)

Select
	cst_lastname
From silver.crm_cust_info
where cst_lastname != trim(cst_lastname)

Select 
	cst_marital_status
	--cst_gndr
From silver.crm_cust_info
where cst_marital_status != trim(cst_marital_status)
--where cst_gndr != trim(cst_gndr)



--- Data Standardizstion and Consistency (Distinct Value for cst_marital_status and cst_gndr)
Select 
 --Distinct cst_gndr
	Distinct cst_marital_status
 From silver.crm_cust_info

 Select * from bronze.crm_cust_info


										---Silver.crm_prd_info---
-- Check duplicate in the primary key
--Expectation: None
Select 
	prd_id,
	count(*)                                     --- Check for duplcate in the primary key
From bronze.crm_prd_info
Group by prd_id
Having count(*) > 1

--- Extraction in the column primary key
Select 
	substring(trim(prd_key),1,5)
from bronze.crm_prd_info 
where
 not exists ( select 
	*
from bronze.crm_prd_info)


Select
	substring(trim(prd_key),7, len(prd_key))
From bronze.crm_prd_info
Where not exists (select sls_prd_key from bronze.crm_sales_details)



--- Check for unwanted space 
Select 
	prd_nm
From silver.crm_prd_info
where prd_nm != trim(prd_nm)

---Check for Null or Negative Values 
Select
	prd_cost
From silver.crm_prd_info
where prd_cost < 0 Or prd_cost Is Null

--- Data Normalization and Consistency
Select 
	Distinct prd_line
from silver.crm_prd_info

select 
	prd_id,
	substring(prd_key,1,5) as cat_id,
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



										--- CRM_sales_details
Select top (1000) * from bronze.crm_sales_details


--- Check if all the column exist in the other table
Select 
	--sls_ord_num
	sls_prd_key
From bronze.crm_sales_details 
--where sls_ord_num != trim(sls_ord_num)
where not exists (select prd_key from silver.crm_prd_info)

Select 
	sls_cust_id
from bronze.crm_sales_details
where not exists ( select cst_id from silver.crm_cust_info)

--- Check for Negate Value and Value not up to 8 character 
Select 
	--sls_order_dt
	--sls_ship_dt
	sls_due_dt
from bronze.crm_sales_details
where sls_due_dt <= 0 or len(sls_due_dt) != 8 



---  Remove Negative and  Null Value from sls_sales and sls_price (for Null in sls_sales cal from Quan * price)
Select sls_sales, sls_quantity, sls_price,
Case
	When sls_sales != sls_quantity*sls_price or sls_sales <= 0 or sls_sales is null Then abs(sls_quantity*sls_price)
	Else sls_sales
	End
from silver.crm_sales_details
where sls_sales != sls_quantity*sls_price or sls_sales <= 0 or sls_sales is null



Select sls_sales, sls_quantity, sls_price,
Case
	When sls_price Is Null Then abs(sls_sales)/sls_quantity
	Else abs(sls_price)
	End as sls_price
from silver.crm_sales_details
where sls_price <= 0 or sls_price is null





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
 
 ------- Clearning the ERP_CUST_AZ12 Table____________
 select * from bronze.erp_CUST_AZ12


 use DataWarehouse

 --- Extraction and checking data quality 
 Select 
	cst_key
From bronze.crm_cust_info
where not exists (select substring(CID,4,len(CID)) from bronze.erp_CUST_AZ12)


select 
	substring(CID,4,len(CID)) 
from bronze.erp_CUST_AZ12
where not exists (Select cst_key From bronze.crm_cust_info)

-- Data Normalization and Consistency

Select 
	Distinct Gen
	From(
Select 
Case
	When trim(GEN) in ('F','Female') then 'Female'
	When trim(GEN) in ('M','Male') then 'Male'
	Else 'N/A'
End as Gen
From bronze.erp_CUST_AZ12)t



Select
	substring(CID,4,len(CID)) as CID,
	BDATE,
	Case
		When trim(GEN) in ('F','Female') then 'Female'
		When trim(GEN) in ('M','Male') then 'Male'
		Else 'N/A'
	End as GEN
From bronze.erp_CUST_AZ12


							-----ERP_LOC_A101
Select 
	Replace(CID,'-','') as CID
From bronze.erp_LOC_A101
Where not exists
(Select
	CID
From silver.erp_CUST_AZ12)

Select 
Distinct CNTRY
From(
Select
	Case
		When trim(CNTRY) In ('US','USA') Then 'United States'
		When trim(CNTRY) In ('DE') Then 'Germany'
		When trim(CNTRY) is Null or trim(CNTRY) = '' Then 'N/A'
		Else trim(CNTRY)
	End as CNTRY
From bronze.erp_LOC_A101)t


--------------------ERP_
Select
	ID
From bronze.erp_PX_CAT_G1V2
Where not exists
(
Select
	cat_id
From silver.crm_prd_info)


Select
	Distinct MAINTENANCE
From bronze.erp_PX_CAT_G1V2


SELECT
	*
FROM BRONZE.erp_PX_CAT_G1V2
