# Data Governance Framework

## 1. Data domains and ownership

| Domain | Data owner | Technical steward | Consumers |
|--------|------------|-------------------|-----------|
| Product / BOM | PLM lead | Data engineering | Costing, production |
| Standard cost | Costing director | ERP admin | Finance, planning |
| Actual / landed | Supply chain finance | Data engineering | Finance, FP&A |
| Reference (FX, vendor) | Master data | MDM team | All |

## 2. Golden record rules

- **Product key:** `style_id || colorway_id || size_code || season_code`
- **Costing key:** `product_key || factory_id || season_code`
- One active BOM version per costing key per effective date range.
- All cost amounts stored in **document currency** and **group currency** with FX rate id.

## 3. Data quality dimensions

| Dimension | Example rule | Threshold |
|-----------|--------------|-----------|
| Completeness | No null `component_id` on active BOM | 100% |
| Consistency | PLM qty within 0.1% of ERP after scrap | 99.5% |
| Timeliness | Gold mart loaded by 06:00 UTC | 95% SLA |
| Validity | Standard cost > 0 for active SKU | 100% |
| Uniqueness | One golden row per costing key | 100% |

## 4. Change management

1. **RFC** for new DQ rule or schema change.
2. **UAT sign-off** from costing + finance before production publish.
3. **Rollback script** for every ERP-integrated release.
4. **Audit log** retained 7 years for standard cost posts.

## 5. Glossary (excerpt)

| Term | Definition |
|------|------------|
| Should-cost | Estimated cost at design / negotiation stage |
| Standard cost | ERP-released cost for planning and inventory |
| Landed cost | FOB + freight + duty + handling in destination market |
| ECO | Engineering change order affecting BOM |
| Size curve | Distribution of units across sizes for a style-color |
