-- Should vs standard vs actual variance with alert flags

WITH latest_standard AS (
    SELECT
        product_key,
        factory_key,
        season_code,
        SUM(amount_group_ccy) AS standard_cost_usd
    FROM gold_costing.fact_cost_component
    WHERE cost_version = 'STANDARD_RELEASED'
      AND effective_date <= CURRENT_DATE
    GROUP BY 1, 2, 3
),
should AS (
    SELECT
        product_key,
        factory_key,
        season_code,
        SUM(amount_group_ccy) AS should_cost_usd
    FROM gold_costing.fact_cost_component
    WHERE cost_version = 'SHOULD_COST_LOCKED'
    GROUP BY 1, 2, 3
),
actual AS (
    SELECT
        v.product_key,
        v.factory_key,
        p.season_code,
        AVG(v.actual_cost_usd) AS actual_cost_usd
    FROM gold_costing.fact_cost_variance v
    JOIN gold_costing.dim_product p ON v.product_key = p.product_key
    WHERE v.as_of_date >= DATEADD(month, -3, CURRENT_DATE)
    GROUP BY 1, 2, 3
)
SELECT
    COALESCE(s.product_key, st.product_key, a.product_key) AS product_key,
    COALESCE(s.factory_key, st.factory_key, a.factory_key) AS factory_key,
    COALESCE(s.season_code, st.season_code, a.season_code) AS season_code,
    s.should_cost_usd,
    st.standard_cost_usd,
    a.actual_cost_usd,
    (st.standard_cost_usd - s.should_cost_usd) / NULLIF(s.should_cost_usd, 0) AS var_should_std_pct,
    (a.actual_cost_usd - st.standard_cost_usd) / NULLIF(st.standard_cost_usd, 0) AS var_std_actual_pct,
    CASE
        WHEN ABS((a.actual_cost_usd - st.standard_cost_usd) / NULLIF(st.standard_cost_usd, 0)) > 0.05
        THEN TRUE ELSE FALSE
    END AS alert_flag
FROM should s
FULL OUTER JOIN latest_standard st
    ON s.product_key = st.product_key
   AND s.factory_key = st.factory_key
   AND s.season_code = st.season_code
FULL OUTER JOIN actual a
    ON COALESCE(s.product_key, st.product_key) = a.product_key
   AND COALESCE(s.factory_key, st.factory_key) = a.factory_key
   AND COALESCE(s.season_code, st.season_code) = a.season_code
WHERE alert_flag = TRUE
ORDER BY var_std_actual_pct DESC NULLS LAST;
