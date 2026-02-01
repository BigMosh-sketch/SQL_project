Use Datawarehouse
/* Script Note 
	1.Create Gold Layer using view 
	2.*Three Table for created in this layer
			gold.dim_customers
			gold.dim_products
			gold.fact_sales
			
	3.*/
			-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Create Gold Layer<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<-----------------------------

			--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>gold.dim_customers<<<<<<<<<<<<<<<<<-----------------------------------

			
			---Customer Information----
			--->>>Dimension Table<<<---------


Create or Alter view gold.dim_Customers as(
Select 
	row_number() over(order by c.cst_id)as customer_key,
	c.cst_id as customer_ID,
	c.cst_key as customer_number,
	c.cst_firstname as firstname,
	c.cst_lastname as  lastname,
	c.cst_marital_status  marital_status,
	Case
		When c.cst_gndr = 'N/A' then Coalesce(cs.GEN,'N/A')
		Else c.cst_gndr
	End as gender,
	cs.BDate as  DOB,
	ci.CNTRY as Country,
	c.cst_create_date as create_date
From silver.crm_cust_info c
Left join silver.erp_LOC_A101 ci
On c.cst_key = ci.CID
Left join silver.erp_CUST_AZ12 cs
On c.cst_key =cs.CID
)



-----Product Information---------------------
 
--->>Dimension Table<<<----

Create or Alter view gold.dim_products as (
Select 
	row_number() over(order by p.prd_id) product_key,
	p.prd_id as product_id,
	p.cat_id as Category_id,
	p.prd_key as product_number,
	p.prd_nm as product_name,
	p.prd_cost as cost,
	pc.CAT as category,
	pc.SUBCAT as subcategory,
	prd_line as product_line,
	pc.MAINTENANCE,
	p.prd_start_dt as start_date,
	p.prd_end_dt as end_date
from silver.crm_prd_info p
Left Join silver.erp_PX_CAT_G1V2 pc
on p.cat_id = pc.ID
where p.prd_end_dt is null  --- Filters out all historical data
)



----->>>>>Record Sales<<<<<<<<<<<<----------------

---->>>>Fact Table<<<<<--------
Create or Alter View gold.fact_sales as (
Select 
	sd.sls_ord_num as Order_number,
	p.product_key,
	c.customer_key,
	sd.sls_order_dt as Order_date,
	sd.sls_ship_dt as ship_date,
	sd.sls_due_dt as due_date,
	sd.sls_sales as sales,
	sd.sls_quantity as quantity,
	sd.sls_price as price
From silver.crm_sales_details sd
Left Join gold.dim_products p
On p.product_number =sd.sls_prd_key
Left Join gold.dim_Customers c
On c.customer_ID = sd.sls_cust_id)

