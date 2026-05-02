TRUNCATE TABLE MARTS.SUMMARY_TRX_USER_COUNT;

INSERT INTO MARTS.SUMMARY_TRX_USER_COUNT
WITH param_date_range AS (
    SELECT FULL_DATE AS REPORT_DATE 
	FROM MFIX_TEST_ASSESSMENT_DB.CORE.DIM_TIME
	WHERE TIME_KEY BETWEEN 20250901 AND 20251031
),

fact_orders AS (
    SELECT
        orders.order_date,
        orders.order_id,
        users.user_id,
        orders.order_status,
        orders.order_platform,
        orders.symbol_id,
        orders.pay_method,
        users.is_premium_user
    from mfix_test_assessment_db.core.fact_orders orders
    left join mfix_test_assessment_db.core.dim_user users on orders.sk_user = users.sk_user and users.is_current=1
),

dim_type AS (

    SELECT order_date, user_id, order_id, order_status, 'order_platform' AS dimension_type, order_platform AS dimension_value FROM fact_orders

    UNION ALL

    SELECT order_date, user_id, order_id, order_status, 'symbol_id' AS dimension_type, symbol_id AS dimension_value FROM fact_orders

    UNION ALL

    SELECT order_date, user_id, order_id, order_status, 'pay_method' AS dimension_type, pay_method AS dimension_value FROM fact_orders
    
    UNION ALL

    SELECT order_date, user_id, order_id, order_status, 'is_premium_user' AS dimension_type , is_premium_user AS dimension_value FROM fact_orders
	
),

agg_dim_type AS (
    SELECT
        order_date as report_date,
        dimension_type,
        dimension_value,
        COUNT(order_id) AS all_trx_count,
        COUNT(DISTINCT user_id) AS all_trx_user_count,
        COUNT(CASE WHEN order_status = 'SUCCESS' THEN order_id END) AS success_trx_count,
		COUNT(DISTINCT CASE WHEN order_status = 'SUCCESS' THEN user_id END) AS success_trx_user_count
    FROM dim_type
    GROUP BY report_date, dimension_type, dimension_value
)
SELECT
    times.report_date,
    agg.dimension_type,
    COALESCE(agg.dimension_value, 'OTHERS') as dimension_value,
    COALESCE(agg.all_trx_count, 0) as all_trx_count,
    COALESCE(agg.all_trx_user_count, 0) as all_trx_user_count,
    COALESCE(agg.success_trx_count, 0) as success_trx_count,
    COALESCE(agg.success_trx_user_count, 0) as success_trx_user_count
FROM param_date_range times
LEFT JOIN agg_dim_type agg ON times.report_date = agg.report_date;