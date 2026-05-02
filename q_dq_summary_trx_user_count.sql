
WITH param_date_range AS (
	---get param range date from dimension time.
    select full_date as report_date 
	from mfix_test_assessment_db.core.dim_time
	where time_key between 20250901 and 20251031
),

-- actual value from mart - summary_trx_user_count

actual_values AS (

    -- 1. get unique symbol_id
    SELECT
        report_date,
        'unique symbol_id count' AS test_case,
        COUNT(DISTINCT dimension_value) AS actual_value
    FROM summary_trx_user_count
    WHERE dimension_type = 'symbol_id'
    GROUP BY report_date

    UNION ALL

    -- 2. get unique payment_platform
    SELECT
        report_date,
        'unique payment_platform count',
        COUNT(DISTINCT dimension_value)
    FROM summary_trx_user_count
    WHERE dimension_type = 'order_platform'
    GROUP BY report_date

    UNION ALL

    -- 3. get unique pay_method
    SELECT
        report_date,
        'unique pay_method count',
        COUNT(DISTINCT dimension_value)
    FROM summary_trx_user_count
    WHERE dimension_type = 'pay_method'
    GROUP BY report_date

    UNION ALL

    -- 4. get unique is_premium_user
    SELECT
        report_date,
        'unique is_premium_user count',
        COUNT(DISTINCT dimension_value)
    FROM summary_trx_user_count
    WHERE dimension_type = 'is_premium_user'
    GROUP BY report_date

    UNION ALL

    -- 5. get null value of payment_platform
    SELECT
        report_date,
        'null value of payment_platform',
        COUNT(1)
    FROM summary_trx_user_count
    WHERE dimension_type = 'order_platform'
      AND dimension_value = 'OTHERS'
    GROUP BY report_date

    UNION ALL

    -- 6. get null value of symbol_id
    SELECT
        report_date,
        'null value of symbol_id',
        COUNT(1)
    FROM summary_trx_user_count
    WHERE dimension_type = 'symbol_id'
      AND dimension_value = 'OTHERS'
    GROUP BY report_date

    UNION ALL

    -- 7. get null value of pay_method
    SELECT
        report_date,
        'null value of pay_method',
        COUNT(1)
    FROM summary_trx_user_count
    WHERE dimension_type = 'pay_method'
      AND dimension_value = 'OTHERS'
    GROUP BY report_date

    UNION ALL

    -- 8. get null value of is_premium_user
    SELECT
        report_date,
        'null value of is_premium_user',
        COUNT(1)
    FROM summary_trx_user_count
    WHERE dimension_type = 'is_premium_user'
      AND dimension_value = 'OTHERS'
    GROUP BY report_date
),

-- expected values base on table dq_test_case expected value
expected_values AS (

    SELECT
        full_date AS report_date,
        10 AS exp_symbol_id,
        5 AS exp_payment_platform,
        6 AS exp_pay_method,
        2 AS exp_is_premium_user,
        0 AS exp_null_payment_platform,
        0 AS exp_null_symbol_id,
        0 AS exp_null_pay_method,
        0 AS exp_null_premium_user
	FROM mfix_test_assessment_db.core.dim_time

),

--unpivot_expected_value
expected_unpivot AS (

    SELECT report_date, 'unique symbol_id count' AS test_case, exp_symbol_id AS expected_value FROM expected_values
    UNION ALL
    SELECT report_date, 'unique payment_platform count', exp_payment_platform FROM expected_values
    UNION ALL
    SELECT report_date, 'unique pay_method count', exp_pay_method FROM expected_values
    UNION ALL
    SELECT report_date, 'unique is_premium_user count', exp_is_premium_user FROM expected_values
    UNION ALL
    SELECT report_date, 'null value of payment_platform', exp_null_payment_platform FROM expected_values
    UNION ALL
    SELECT report_date, 'null value of symbol_id', exp_null_symbol_id FROM expected_values
    UNION ALL
    SELECT report_date, 'null value of pay_method', exp_null_pay_method FROM expected_values
    UNION ALL
    SELECT report_date, 'null value of is_premium_user', exp_null_premium_user FROM expected_values
)

--check quality of actual value by report date compare with test case rules
SELECT
    d.report_date,
    e.test_case,
    e.expected_value,
    COALESCE(a.actual_value, 0) AS actual_value,
    CASE 
        WHEN COALESCE(a.actual_value, 0) = e.expected_value THEN 'PASSED'
		WHEN COALESCE(a.actual_value, 0) != e.expected_value THEN 'FAILED'
        ELSE NULL
    END AS status
FROM param_date_range d
LEFT JOIN expected_unpivot e ON d.report_date = e.report_date
LEFT JOIN actual_values a ON d.report_date = a.report_date AND e.test_case = a.test_case
ORDER BY d.report_date asc, e.test_case asc
