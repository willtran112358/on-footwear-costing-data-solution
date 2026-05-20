# 90-Day Implementation Roadmap

## Phase 0 — Discover (weeks 1–3)

| Milestone | Deliverable | Owner |
|-----------|-------------|-------|
| M0.1 | Stakeholder map and interview synthesis | Data lead |
| M0.2 | Source system inventory and field mapping | Data + IT |
| M0.3 | Pain quantification ($ and hours) | Data + costing |

**Exit criteria:** Signed problem statement and pilot category (e.g. one performance running line).

## Phase 1 — Foundation (weeks 4–6)

| Milestone | Deliverable | Owner |
|-----------|-------------|-------|
| M1.1 | Golden keys and DDL in dev | Data engineering |
| M1.2 | DQ rules v1 (BOM + standard cost) | Data lead |
| M1.3 | Glossary v1 in catalog | Data + costing |

**Exit criteria:** Synthetic end-to-end pipeline runs in dev.

## Phase 2 — Integrate (weeks 7–10)

| Milestone | Deliverable | Owner |
|-----------|-------------|-------|
| M2.1 | PLM and ERP ingest to bronze/silver | Data engineering |
| M2.2 | Daily BOM reconciliation job | Data lead |
| M2.3 | Power BI costing control tower (pilot) | Analytics |

**Exit criteria:** Pilot category live with < 1% unresolved BOM exceptions.

## Phase 3 — Adopt (weeks 11–12)

| Milestone | Deliverable | Owner |
|-----------|-------------|-------|
| M3.1 | UAT and training for costing analysts | Data + costing |
| M3.2 | Hypercare runbook and on-call | Data engineering |
| M3.3 | Executive readout and scale plan | Data lead |

## Target KPIs (pilot)

| KPI | Baseline (typical) | Target |
|-----|-------------------|--------|
| Seasonal roll-up cycle time | 10–15 days | ≤ 5 days |
| Unresolved BOM mismatches | 3–5% | < 0.5% |
| Manual Excel bridges | High | −60% effort |

## Risks and mitigations

| Risk | Mitigation |
|------|------------|
| ERP freeze during close | Schedule releases outside close window |
| PLM data quality | Exception queue + PLM owner SLA |
| Scope creep | Fixed pilot category; phase-2 backlog |
