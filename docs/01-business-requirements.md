# Business Requirements — Footwear Costing Data Management

## 1. Business context

Sport footwear brands scale through **seasonal collections**, **colorways**, and **size curves**. Costing spans:

- **Should-cost / pre-cost** — development and sourcing negotiation
- **Standard cost** — ERP seasonal roll and margin planning
- **Actual / landed cost** — purchase orders, freight, duty, FX
- **Master data** — style, colorway, size, factory, routing, UoM, vendor, incoterms

A Senior Data Specialist in costing must **own data end-to-end**, enforce **governance**, partner with IT / supply chain / costing / production, and deliver **automation** with measurable quality.

## 2. Stakeholders and RACI (summary)

| Activity | Costing | Supply chain | PLM | ERP / IT | Finance | Data lead |
|----------|---------|--------------|-----|----------|---------|-----------|
| BOM golden definition | C | C | A | R | I | R |
| Standard cost release | A | C | I | R | C | R |
| DQ rules and monitoring | C | C | C | C | C | **A** |
| Variance root-cause analysis | A | R | C | C | A | R |

*A = Accountable, R = Responsible, C = Consulted, I = Informed*

## 3. Pain points (as-is, industry-typical)

1. **PLM BOM ≠ ERP BOM** after engineering change orders (ECO).
2. **Excel as system of record** for should-cost — does not scale per season.
3. **Landed cost** updates lag behind freight and FX moves.
4. **No single SKU cost timeline** — difficult to audit who changed what and when.
5. **Size curve and yield loss** inconsistent across factory pack definitions.
6. **Fragmented reporting** — BI built from manual exports.

## 4. Functional requirements

| ID | Requirement | Priority | Success metric |
|----|-------------|----------|----------------|
| BR-01 | Golden costing key per active SKU (style-color-size-factory-season) | P0 | 99% active SKUs with one golden key |
| BR-02 | Daily PLM–ERP BOM reconciliation with exception queue | P0 | <0.5% unresolved mismatches older than 48h |
| BR-03 | Should vs standard vs actual variance reporting | P0 | Supports financial close at T+3 |
| BR-04 | Lineage: every cost field maps to source system and version | P1 | 100% of monetary fields have `source_id` |
| BR-05 | Threshold-based alerts (variance, BOM drift, missing FX) | P1 | Mean time to resolve mismatch < 2 business days |
| BR-06 | UAT pack and rollback plan for cost release | P0 | Zero unplanned production rollback in pilot season |
| BR-07 | Data catalog and business glossary (FOB, LDP, COGS, etc.) | P2 | Glossary adopted by at least three functions |

## 5. Non-functional requirements

- **Freshness:** costing mart refreshed daily (T+1); critical BOM paths target near-real-time.
- **Quality:** automated DQ with ownership per domain.
- **Security:** RBAC by region and factory; no unnecessary PII in costing mart.
- **Compliance:** immutable change log for standard cost postings (SOX-friendly).

## 6. Out of scope (pilot)

- Full PLM replacement
- Automated ML price optimization (future phase)
- Direct ERP write-back without UAT sign-off
