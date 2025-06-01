/* 
 MUC DICH : LOAD SILVER LAYER (bronze->silver)
 Procedure này thể hiện một qúa tình ETL  từ việc trích xuất dữ liệu từ bronze layer và chuyển đổi sau đó tải xuống silver layer
 
 Chú ý : Khi thụư thi chương trình dữ liệu từ lớp silver sẽ được xóa héet và cập nhật lại

 Use : EXEC silver.Load_silver

*/
--Load crm_cust_info
CREATE OR ALTER PROCEDURE silver.Load_silver AS 
BEGIN
	DECLARE @start_time DATETIME , @end_time DATETIME,@start_batch_time DATETIME,@end_batch_time DATETIME
	BEGIN TRY
		SET @start_batch_time = GETDATE();
		PRINT'============================'
		PRINT'Start batch time'
		PRINT'============================'

		PRINT'----------------------------'
		PRINT'Loading CRM'
		PRINT'----------------------------'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			trim(cst_firstname),
			trim(cst_lastname),
			CASE 
				WHEN cst_marital_status = 'S' THEN 'Single'
				WHEN cst_marital_status = 'M' THEN 'Married'
				ELSE 'n\a'
			END cst_marital_status,
			CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' then 'Female'
				 WHEN UPPER(TRIM(cst_gndr)) =  'M' THEN 'Male'
				ELSE 'n/a'
			END cst_gndr,
			cst_create_date
		FROM (SELECT *,ROW_NUMBER() OVER(partition by cst_id order by cst_create_date DESC) as flag_last 
		FROM  bronze.crm_cust_info
		WHERE cst_id is not null) as sub
		WHERE flag_last =1 ;
		SET @end_time =GETDATE();
		PRINT 'Thoi gian load bang crm_cust_info la' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR)  + ' SECOND';
		-- INSERT CRM_PRD
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserting Data Into: silver.crm_prd_info';
		insert into silver.crm_prd_info(
			prd_id, 
			cat_id ,
			prd_key,
			prd_nm ,
			prd_cost, 
			prd_line,
			prd_start_dt, 
			prd_end_dt
		)
		SELECT 
			prd_id ,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') cat_id,
			SUBSTRING(prd_key , 7, len(prd_key)) as prd_key,
			prd_nm,
			ISNULL(prd_cost,0) as prd_cost, 
			CASE UPPER(TRIM(prd_line))
				WHEN 'R' THEN 'Road'
				WHEN 'M' THEN 'Moutain'
				WHEN 'S' THEN 'Short'
				WHEN 'T' THEN 'Touring'
				ELSE 'a/n'
			END as prd_line,
			prd_start_dt,
			LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)
			AS prd_end_dt
		FROM bronze.crm_prd_info;
		SET @end_time =GETDATE();
		PRINT 'Thoi gian load bang silver.crm_prd_info la' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR)  + ' SECOND';
		--Load Sales 
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting Data Into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END as sls_order_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END as sls_ship_dt,
			CASE 
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END as sls_due_dt,

			CASE WHEN sls_sales is null or sls_sales < 0 
				 THEN  sls_price * sls_quantity 
				 ELSE sls_sales
			END AS sls_sales ,
			sls_quantity,
			CASE WHEN sls_price is null or sls_price < 0 
				 THEN  sls_sales / sls_quantity
				 ELSE sls_price 
			END AS sls_price 
		FROM bronze.crm_sales_details
		SET @end_time =GETDATE();
		PRINT 'Thoi gian load bang silver.crm_sales_details la' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR)  + ' SECOND';
		-- Load erp_cust

		PRINT'----------------------------'
		PRINT'Loading ERP'
		PRINT'----------------------------'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Inserting Data Into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(
			cid, 
			bdate, 
			gen
		)
		SELECT
			CASE WHEN cid like'NAS%' THEN SUBSTRING(cid,4 ,LEN(cid))
				else cid 
			end as cid,
			CASE WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END as bdate,
			CASE WHEN UPPER(TRIM(gen)) in ('F','FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) in ('M','MALE') THEN 'Male'
				ELSE gen
			END AS  gen 
		FROM bronze.erp_cust_az12
		SET @end_time =GETDATE();
		PRINT 'Thoi gian load bang silver.erp_cust_az12 la' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR)  + ' SECOND';
		--Load Loc
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101(
			cid, 
			cntry
		)
		SELECT 
			REPLACE(cid,'-','') as cid,
			CASE WHEN cntry in ('US','USA') THEN 'United States'
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) ='' OR cntry IS NULL THEN 'n\a'
				ELSE TRIM(cntry)
			END AS cntry
		FROM bronze.erp_loc_a101
		SET @end_time =GETDATE();
		PRINT 'Thoi gian load bang silver.erp_loc_a101 la' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR)  + ' SECOND';
		--Load erp_cat
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT 
			id,
			cat, 
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2
		SET @end_time =GETDATE();
		PRINT 'Thoi gian load bang silver.erp_px_cat_g1v2 la' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR)  + ' SECOND';
		SET @end_batch_time =GETDATE() 
		PRINT'======================================================'
		PRINT' THOI GIAN CUA QUA TRINH LOAD LA ' + CAST(DATEDIFF(second,@start_batch_time,@end_batch_time) as varchar)  + ' SECOND';
	END TRY
	BEGIN CATCH
		PRINT 'LOI QUA TRINH LOAD' + ERROR_NUMBER()
		PRINT 'LOI QUA TRINH LOAD' + ERROR_MESSAGE() 
	END CATCH
END;
