# Footwear Costing Data Solution (Case Study)

> 🇻🇳 **Tiếng Việt:** [README_VI.md](README_VI.md)

Enterprise data management case study for **footwear costing**: governance, PLM–ERP alignment, should-cost vs actual variance, and scalable analytics.

**Context (public job description):** Senior Specialist – Data Management – Footwear Costing at On (Ho Chi Minh City).

**Disclaimer:** This repository uses **synthetic data** and a **hypothetical architecture**. It is an independent portfolio project and is **not affiliated with On AG**.

---

## Architecture overview

### As-is — fragmented costing landscape

Typical pain: Excel sits between systems; BOM versions drift; reporting is manual.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'fontFamily': 'Segoe UI, sans-serif', 'fontSize': '14px'}}}%%
flowchart LR
  subgraph SRC["🗂️ Source Systems"]
    direction TB
    PLM["👟 PLM<br/>BOM · ECO"]
    ERP["📦 ERP<br/>Standard · Actual"]
    SCM["🚢 Supply Chain<br/>Freight · FX"]
  end

  subgraph RISK["⚠️ Manual Layer"]
    XLS["📊 Excel<br/>Costing Models"]
  end

  subgraph OUT["📈 Reporting"]
    PBI["📉 Power BI<br/>Ad-hoc exports"]
  end

  PLM -->|"manual export"| XLS
  ERP -->|"reports"| XLS
  SCM -->|"lookup tables"| XLS
  XLS --> PBI
  PLM -.->|"batch lag · version drift"| ERP

  style SRC fill:#E3F2FD,stroke:#1565C0,stroke-width:2px,color:#0D47A1
  style RISK fill:#FFEBEE,stroke:#C62828,stroke-width:2px,color:#B71C1C
  style OUT fill:#FFF8E1,stroke:#F9A825,stroke-width:2px,color:#E65100
  style PLM fill:#42A5F5,stroke:#1565C0,color:#fff
  style ERP fill:#66BB6A,stroke:#2E7D32,color:#fff
  style SCM fill:#AB47BC,stroke:#6A1B9A,color:#fff
  style XLS fill:#EF5350,stroke:#C62828,color:#fff
  style PBI fill:#FFA726,stroke:#E65100,color:#fff
```

| Symptom | Root cause | Business cost |
|---------|------------|---------------|
| Margin surprise at season gate | Stale should-cost vs released standard | Delayed pricing decisions |
| Factory disputes on material usage | BOM version mismatch | Rework, claim cycles |
| Slow close | Manual actual cost allocation | Finance overtime |

---

### To-be — governed costing data platform

Event-driven ingest, medallion lakehouse, DQ gate, certified consumption.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'fontFamily': 'Segoe UI, sans-serif', 'fontSize': '14px'}}}%%
flowchart TB
  subgraph SOURCES["🗂️ Sources"]
    direction LR
    PLM2["👟 PLM CDC"]
    ERP2["📦 ERP"]
    TMS["🚢 TMS / Freight"]
    MDM["🏷️ MDM · FX"]
  end

  subgraph INGEST["⚡ Ingestion"]
    BUS["📡 Kafka / Event Bus"]
    ELT["🔄 ELT · dbt / Spark"]
  end

  subgraph LAKE["🏛️ Medallion Lakehouse"]
    direction LR
    BRZ[("🥉 Bronze<br/>Raw")]
    SLV[("🥈 Silver<br/>Conformed")]
    GLD[("🥇 Gold<br/>Costing Mart")]
  end

  subgraph QUALITY["✅ Quality & Governance"]
    DQ["🛡️ DQ Engine<br/>+ Alerts"]
    CAT["📚 Catalog<br/>+ Lineage"]
  end

  subgraph CONSUME["📊 Consumption"]
    direction LR
    PBI2["📈 Power BI<br/>Control Tower"]
    SQL2["🔍 SQL Analytics"]
  end

  PLM2 --> BUS
  ERP2 --> BUS
  TMS --> BUS
  MDM --> BUS
  BUS --> ELT --> BRZ --> SLV --> GLD
  SLV --> DQ
  DQ --> CAT
  GLD --> PBI2
  GLD --> SQL2

  style SOURCES fill:#E8EAF6,stroke:#3949AB,stroke-width:2px,color:#1A237E
  style INGEST fill:#E0F7FA,stroke:#00838F,stroke-width:2px,color:#006064
  style LAKE fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px,color:#1B5E20
  style QUALITY fill:#FFF3E0,stroke:#EF6C00,stroke-width:2px,color:#E65100
  style CONSUME fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2px,color:#4A148C
  style PLM2 fill:#42A5F5,stroke:#1565C0,color:#fff
  style ERP2 fill:#66BB6A,stroke:#2E7D32,color:#fff
  style TMS fill:#AB47BC,stroke:#6A1B9A,color:#fff
  style MDM fill:#78909C,stroke:#455A64,color:#fff
  style BUS fill:#26C6DA,stroke:#00838F,color:#fff
  style ELT fill:#26A69A,stroke:#00695C,color:#fff
  style BRZ fill:#A1887F,stroke:#4E342E,color:#fff
  style SLV fill:#90A4AE,stroke:#37474F,color:#fff
  style GLD fill:#FFD54F,stroke:#F57F17,color:#1a1a1a
  style DQ fill:#FF7043,stroke:#D84315,color:#fff
  style CAT fill:#FFB74D,stroke:#E65100,color:#fff
  style PBI2 fill:#7E57C2,stroke:#4527A0,color:#fff
  style SQL2 fill:#5C6BC0,stroke:#283593,color:#fff
```

---

### Target costing workflow

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'fontFamily': 'Segoe UI, sans-serif'}}}%%
sequenceDiagram
  autonumber
  participant PLM as 👟 PLM
  participant BUS as 📡 Event Bus
  participant SLV as 🥈 Silver
  participant DQ as 🛡️ DQ
  participant COST as 💰 Costing Team
  participant ERP as 📦 ERP
  participant GLD as 🥇 Gold Mart
  participant BI as 📈 Power BI

  PLM->>BUS: BOM / ECO change event
  BUS->>SLV: Conform & version BOM
  SLV->>DQ: PLM ↔ ERP reconciliation
  alt Mismatch detected
    DQ-->>COST: Exception queue alert
    COST->>ERP: Approved standard cost release
  else Within tolerance
    DQ->>SLV: Pass · certify dataset
  end
  SLV->>GLD: Refresh costing mart
  GLD->>BI: Variance & margin dashboards
  BI-->>COST: Threshold breach alert
```

---

## Pain points addressed

| Pain point | Business impact | Solution pillar |
|------------|-----------------|-----------------|
| BOM / version drift between PLM and ERP | Wrong standard cost, margin leakage | Golden record + daily reconciliation |
| Manual Excel costing roll-ups | Slow seasonal costing, human error | Automated pipeline + data quality rules |
| FX / freight / MOQ volatility | Unstable landed cost | Parameterized cost engine + alerts |
| Multi-plant, multi-currency operations | Inconsistent COGS | Master data hub + FX policy |
| Weak lineage and ownership | Audit risk, slow UAT | Data governance + catalog |

## Repository structure

```
docs/           Business requirements, as-is / to-be architecture, governance, roadmap
sql/            DDL and reconciliation / variance queries
python/         Ingest patterns and reconciliation scripts
powerbi/        Semantic model notes for costing control tower
data/           Synthetic sample dataset
```

## Quick start

```bash
pip install -r python/requirements.txt
python python/costing_reconciliation.py
```

## How this maps to the role

| Job requirement | Evidence in this repo |
|-----------------|------------------------|
| End-to-end costing data ownership | BRD, gold-layer DDL, governance doc |
| Project leadership | 90-day implementation roadmap |
| ERP / PLM / costing systems | As-is / to-be architecture, BOM reconciliation SQL |
| SQL, Power BI | `sql/`, Power BI model documentation |
| Automation & process improvement | Python ingest + DQ alerting patterns |
| Cross-functional stakeholder management | RACI and phased rollout |

## License

MIT — see [LICENSE](LICENSE).
