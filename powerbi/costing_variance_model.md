# Power BI — Costing Control Tower (Semantic Model)

## Star schema (from gold mart)

**Dimensions**

- `dim_product` — style, colorway, size, season, category
- `dim_factory` — site, country, region
- `dim_calendar` — fiscal week, season gate dates
- `dim_vendor` — tier-1 material suppliers

**Facts**

- `fact_cost_variance` — should / standard / actual at SKU-factory-season
- `fact_bom_exception` — output of `dq_bom_reconciliation.sql`
- `fact_cost_component` — drill to material / labor / overhead

## Report pages

1. **Executive margin risk** — top SKUs by `var_std_actual_pct`, trend by season
2. **BOM mismatch queue** — open PLM vs ERP exceptions, aging buckets
3. **Factory actual vs standard** — heatmap by factory and category
4. **Component Pareto** — drivers of variance (material, freight, FX)

## Measures (DAX examples)

```dax
Var Std vs Actual % =
DIVIDE(
    SUM(fact_cost_variance[actual_cost_usd]) - SUM(fact_cost_variance[standard_cost_usd]),
    SUM(fact_cost_variance[standard_cost_usd])
)

Alert Count =
CALCULATE(
    COUNTROWS(fact_cost_variance),
    fact_cost_variance[alert_flag] = TRUE
)
```

## Refresh and governance

- Daily refresh after gold mart SLA (06:00 UTC target)
- Certified dataset badge after UAT sign-off from costing and finance
- Row-level security by `region` and `factory_id`
