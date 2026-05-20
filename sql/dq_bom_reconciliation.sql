-- Unresolved PLM vs ERP BOM mismatches (quantity or missing component)

WITH plm AS (
    SELECT
        product_key,
        component_id,
        effective_date,
        SUM(quantity * (1 + scrap_rate)) AS plm_qty
    FROM silver.fact_bom_line
    WHERE source_system = 'PLM'
      AND is_current = TRUE
    GROUP BY 1, 2, 3
),
erp AS (
    SELECT
        product_key,
        component_id,
        effective_date,
        SUM(quantity) AS erp_qty
    FROM silver.fact_bom_line
    WHERE source_system = 'ERP'
      AND is_current = TRUE
    GROUP BY 1, 2, 3
),
reconciled AS (
    SELECT
        COALESCE(p.product_key, e.product_key)     AS product_key,
        COALESCE(p.component_id, e.component_id)   AS component_id,
        COALESCE(p.effective_date, e.effective_date) AS effective_date,
        p.plm_qty,
        e.erp_qty,
        ABS(COALESCE(p.plm_qty, 0) - COALESCE(e.erp_qty, 0)) AS qty_delta,
        CASE
            WHEN p.product_key IS NULL THEN 'MISSING_IN_PLM'
            WHEN e.product_key IS NULL THEN 'MISSING_IN_ERP'
            WHEN ABS(p.plm_qty - e.erp_qty) > 0.001 THEN 'QTY_MISMATCH'
            ELSE 'OK'
        END AS dq_status
    FROM plm p
    FULL OUTER JOIN erp e
        ON p.product_key = e.product_key
       AND p.component_id = e.component_id
       AND p.effective_date = e.effective_date
)
SELECT *
FROM reconciled
WHERE dq_status <> 'OK'
ORDER BY qty_delta DESC, product_key, component_id;
