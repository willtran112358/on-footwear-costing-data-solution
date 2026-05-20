# Giải pháp Dữ liệu Costing Giày Thể thao (Case Study)

> 🇬🇧 **English:** [README.md](README.md)

Case study quản trị dữ liệu doanh nghiệp cho **costing ngành giày**: governance, đồng bộ PLM–ERP, phân tích chênh lệch should-cost / standard / actual, và analytics có thể mở rộng.

**Bối cảnh (JD công khai):** Senior Specialist – Data Management – Footwear Costing tại On (TP. Hồ Chí Minh).

**Lưu ý:** Repo dùng **dữ liệu giả lập** và **kiến trúc giả định**. Đây là dự án portfolio độc lập, **không liên kết với On AG**.

---

## Tổng quan kiến trúc

### Hiện trạng (As-is) — hệ thống costing phân mảnh

Vấn đề điển hình: Excel là cầu nối thủ công; BOM lệch phiên bản; báo cáo không tự động.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'fontFamily': 'Segoe UI, sans-serif', 'fontSize': '14px'}}}%%
flowchart LR
  subgraph SRC["🗂️ Hệ thống nguồn"]
    direction TB
    PLM["👟 PLM<br/>BOM · ECO"]
    ERP["📦 ERP<br/>Standard · Actual"]
    SCM["🚢 Chuỗi cung ứng<br/>Freight · FX"]
  end

  subgraph RISK["⚠️ Tầng thủ công"]
    XLS["📊 Excel<br/>Mô hình costing"]
  end

  subgraph OUT["📈 Báo cáo"]
    PBI["📉 Power BI<br/>Export thủ công"]
  end

  PLM -->|"export thủ công"| XLS
  ERP -->|"báo cáo"| XLS
  SCM -->|"bảng tra cứu"| XLS
  XLS --> PBI
  PLM -.->|"độ trễ batch · lệch version"| ERP

  style SRC fill:#E3F2FD,stroke:#1565C0,stroke-width:2px,color:#0D47A1
  style RISK fill:#FFEBEE,stroke:#C62828,stroke-width:2px,color:#B71C1C
  style OUT fill:#FFF8E1,stroke:#F9A825,stroke-width:2px,color:#E65100
  style PLM fill:#42A5F5,stroke:#1565C0,color:#fff
  style ERP fill:#66BB6A,stroke:#2E7D32,color:#fff
  style SCM fill:#AB47BC,stroke:#6A1B9A,color:#fff
  style XLS fill:#EF5350,stroke:#C62828,color:#fff
  style PBI fill:#FFA726,stroke:#E65100,color:#fff
```

| Triệu chứng | Nguyên nhân gốc | Tác động kinh doanh |
|-------------|-----------------|---------------------|
| Lệch margin khi mở season | Should-cost cũ so với standard đã release | Trễ quyết định giá |
| Tranh chấp với nhà máy về định mức | BOM PLM ≠ ERP | Rework, claim |
| Đóng sổ chậm | Phân bổ actual cost thủ công | OT cho Finance |

---

### Mục tiêu (To-be) — nền tảng dữ liệu costing có governance

Ingest theo sự kiện, lakehouse medallion, cổng DQ, consumption đã chứng nhận.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'fontFamily': 'Segoe UI, sans-serif', 'fontSize': '14px'}}}%%
flowchart TB
  subgraph SOURCES["🗂️ Nguồn dữ liệu"]
    direction LR
    PLM2["👟 PLM CDC"]
    ERP2["📦 ERP"]
    TMS["🚢 TMS / Freight"]
    MDM["🏷️ MDM · FX"]
  end

  subgraph INGEST["⚡ Thu thập & xử lý"]
    BUS["📡 Kafka / Event Bus"]
    ELT["🔄 ELT · dbt / Spark"]
  end

  subgraph LAKE["🏛️ Lakehouse Medallion"]
    direction LR
    BRZ[("🥉 Bronze<br/>Raw")]
    SLV[("🥈 Silver<br/>Chuẩn hóa")]
    GLD[("🥇 Gold<br/>Costing Mart")]
  end

  subgraph QUALITY["✅ Chất lượng & Governance"]
    DQ["🛡️ DQ Engine<br/>+ Cảnh báo"]
    CAT["📚 Catalog<br/>+ Lineage"]
  end

  subgraph CONSUME["📊 Sử dụng"]
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

### Quy trình costing mục tiêu

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'fontFamily': 'Segoe UI, sans-serif'}}}%%
sequenceDiagram
  autonumber
  participant PLM as 👟 PLM
  participant BUS as 📡 Event Bus
  participant SLV as 🥈 Silver
  participant DQ as 🛡️ DQ
  participant COST as 💰 Team Costing
  participant ERP as 📦 ERP
  participant GLD as 🥇 Gold Mart
  participant BI as 📈 Power BI

  PLM->>BUS: Sự kiện thay đổi BOM / ECO
  BUS->>SLV: Chuẩn hóa & versioning BOM
  SLV->>DQ: Đối soát PLM ↔ ERP
  alt Phát hiện lệch
    DQ-->>COST: Cảnh báo hàng đợi exception
    COST->>ERP: Release standard cost đã duyệt
  else Trong ngưỡng cho phép
    DQ->>SLV: Pass · chứng nhận dataset
  end
  SLV->>GLD: Refresh costing mart
  GLD->>BI: Dashboard variance & margin
  BI-->>COST: Cảnh báo vượt ngưỡng
```

---

## Mẫu code theo kiến trúc (đọc nhanh)

Các đoạn dưới **rút gọn** từ `python/` và `sql/` — map trực tiếp vào sơ đồ To-be ở trên.

| Tầng kiến trúc | File đầy đủ | Việc làm |
|----------------|-------------|----------|
| **Ingest → Bronze** | `python/ingest_plm_bom.py` | Nhận BOM từ PLM, tạo `event_id` idempotent, đẩy event bus |
| **Silver → DQ** | `sql/dq_bom_reconciliation.sql` | Đối soát BOM PLM vs ERP, xuất exception queue |
| **Gold → Alert** | `python/costing_reconciliation.py` | So sánh should / standard / actual, gắn cờ vượt ngưỡng |
| **Gold schema** | `sql/ddl_costing_gold_layer.sql` | Định nghĩa bảng mart costing |

### 1) Ingest PLM → Bronze (Kafka / landing)

```python
# python/ingest_plm_bom.py — tầng Ingest
def bom_line_hash(product_key, component_id, qty, uom, effective_date) -> str:
    payload = f"{product_key}|{component_id}|{qty}|{uom}|{effective_date}"
    return hashlib.sha256(payload.encode()).hexdigest()

def to_bronze_event(row: dict) -> dict:
    return {
        "event_id": bom_line_hash(...),      # trùng lặp → cùng key, không double-count
        "source": "PLM",
        "topic": "costing.plm.bom.v1",       # map vào Event Bus trong sơ đồ
        "ingested_at": datetime.now(timezone.utc).isoformat(),
        "payload": row,                       # BOM line thô
    }
```

**Ý nghĩa:** Mỗi dòng BOM là một event; ELT phía sau ghi vào **Bronze** rồi chuẩn hóa lên **Silver**.

---

### 2) Đối soát BOM — Silver + DQ

```sql
-- sql/dq_bom_reconciliation.sql — cổng DQ trước khi publish Gold
WITH plm AS (
    SELECT product_key, component_id, effective_date,
           SUM(quantity * (1 + scrap_rate)) AS plm_qty
    FROM silver.fact_bom_line
    WHERE source_system = 'PLM' AND is_current = TRUE
    GROUP BY 1, 2, 3
),
erp AS (
    SELECT product_key, component_id, effective_date,
           SUM(quantity) AS erp_qty
    FROM silver.fact_bom_line
    WHERE source_system = 'ERP' AND is_current = TRUE
    GROUP BY 1, 2, 3
)
SELECT product_key, component_id,
       plm_qty, erp_qty,
       CASE
           WHEN p.product_key IS NULL THEN 'MISSING_IN_PLM'
           WHEN e.product_key IS NULL THEN 'MISSING_IN_ERP'
           WHEN ABS(p.plm_qty - e.erp_qty) > 0.001 THEN 'QTY_MISMATCH'
           ELSE 'OK'
       END AS dq_status
FROM plm p
FULL OUTER JOIN erp e USING (product_key, component_id, effective_date)
WHERE dq_status <> 'OK';   -- chỉ giữ exception → queue cho team Costing
```

**Ý nghĩa:** Khớp với bước **“Đối soát PLM ↔ ERP”** trong sequence diagram — lệch BOM thì **không** cho costing chạy im lặng.

---

### 3) Variance should / standard / actual — Gold + cảnh báo

```python
# python/costing_reconciliation.py — tầng Gold / Consumption
THRESHOLD_PCT = 0.05   # vượt 5% → alert Power BI / email

def enrich_variance(df: pd.DataFrame) -> pd.DataFrame:
    out = df.copy()
    out["var_should_std_pct"] = (out["standard"] - out["should"]) / out["should"]
    out["var_std_actual_pct"] = (out["actual"] - out["standard"]) / out["standard"]
    out["alert"] = out["var_std_actual_pct"].abs() > THRESHOLD_PCT
    return out

# Ví dụ output (data/sample_costing.csv):
#   SKU              should  standard  actual  alert
#   LIFE-02-WHT-44   42.00   41.50     44.80   True  → điều tra freight / FX / yield
```

**Ý nghĩa:** Mart **Gold** (`fact_cost_variance`) phục vụ Control Tower; costing analyst nhận **driver_hint** thay vì chỉ nhìn số thô.

---

### 4) DDL Gold layer (schema mart)

```sql
-- sql/ddl_costing_gold_layer.sql — ví dụ bảng trung tâm
CREATE TABLE gold_costing.fact_cost_variance (
    variance_key        VARCHAR(64) PRIMARY KEY,
    product_key         VARCHAR(64) NOT NULL,   -- style-color-size-season
    factory_key         VARCHAR(32) NOT NULL,
    should_cost_usd     DECIMAL(18, 4),
    standard_cost_usd   DECIMAL(18, 4),
    actual_cost_usd     DECIMAL(18, 4),
    var_std_actual_pct  DECIMAL(10, 6),
    alert_flag          BOOLEAN DEFAULT FALSE,
    as_of_date          DATE NOT NULL
);
```

**Ý nghĩa:** Một **golden grain** cho mỗi SKU–factory–kỳ; Power BI / SQL đọc từ đây thay vì Excel.

---

### Chạy local để xem output

```bash
pip install -r python/requirements.txt
python python/ingest_plm_bom.py          # in JSON event Bronze
python python/costing_reconciliation.py # in bảng variance + số alert
```

---

## Pain point được giải quyết

| Pain point | Tác động kinh doanh | Trụ cột giải pháp |
|------------|---------------------|-------------------|
| BOM / version lệch giữa PLM và ERP | Sai standard cost, rò margin | Golden record + đối soát hàng ngày |
| Tổng hợp costing bằng Excel | Chậm theo season, lỗi thủ công | Pipeline tự động + rule DQ |
| Biến động FX / freight / MOQ | Landed cost không ổn định | Cost engine tham số hóa + alert |
| Đa nhà máy, đa tiền tệ | COGS không nhất quán | MDM hub + chính sách FX |
| Thiếu lineage & ownership | Rủi ro audit, UAT chậm | Governance + data catalog |

## Cấu trúc repository

```
docs/           BRD, kiến trúc as-is / to-be, governance, roadmap
sql/            DDL và query đối soát / variance
python/         Mẫu ingest và reconciliation
powerbi/        Ghi chú semantic model control tower
data/           Dataset mẫu giả lập
```

## Chạy thử nhanh

```bash
pip install -r python/requirements.txt
python python/costing_reconciliation.py
```

## Ánh xạ với JD

| Yêu cầu công việc | Bằng chứng trong repo |
|-------------------|------------------------|
| Sở hữu end-to-end dữ liệu costing | BRD, DDL gold layer, doc governance |
| Lãnh đạo dự án | Roadmap triển khai 90 ngày |
| ERP / PLM / hệ thống costing | Kiến trúc, SQL đối soát BOM |
| SQL, Power BI | Thư mục `sql/`, tài liệu Power BI |
| Tự động hóa & cải tiến quy trình | Python ingest + pattern cảnh báo DQ |
| Phối hợp đa bộ phận | RACI và rollout theo phase |

## Giấy phép

MIT — xem [LICENSE](LICENSE).
