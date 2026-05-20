-- Gold-layer DDL (illustrative warehouse: Snowflake / BigQuery / Synapse compatible)

CREATE SCHEMA IF NOT EXISTS gold_costing;

CREATE TABLE IF NOT EXISTS gold_costing.dim_product (
    product_key           VARCHAR(64) PRIMARY KEY,
    style_id              VARCHAR(32) NOT NULL,
    style_name            VARCHAR(128),
    colorway_id           VARCHAR(32) NOT NULL,
    size_code             VARCHAR(8) NOT NULL,
    season_code           VARCHAR(16) NOT NULL,
    category              VARCHAR(32),  -- road, trail, lifestyle
    is_active             BOOLEAN DEFAULT TRUE,
    valid_from            DATE NOT NULL,
    valid_to              DATE,
    created_at            TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS gold_costing.dim_factory (
    factory_key           VARCHAR(32) PRIMARY KEY,
    factory_id            VARCHAR(16) NOT NULL,
    factory_name          VARCHAR(128),
    country_code          CHAR(2),
    region                VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS gold_costing.fact_bom_line (
    bom_line_key          VARCHAR(64) PRIMARY KEY,
    product_key           VARCHAR(64) NOT NULL,
    component_id          VARCHAR(32) NOT NULL,
    component_desc        VARCHAR(256),
    quantity              DECIMAL(18, 6) NOT NULL,
    uom                   VARCHAR(8) NOT NULL,
    scrap_rate            DECIMAL(8, 6) DEFAULT 0,
    source_system         VARCHAR(8) NOT NULL,  -- PLM, ERP
    effective_date        DATE NOT NULL,
    is_current            BOOLEAN DEFAULT TRUE,
    ingested_at           TIMESTAMP_NTZ NOT NULL,
    FOREIGN KEY (product_key) REFERENCES gold_costing.dim_product(product_key)
);

CREATE TABLE IF NOT EXISTS gold_costing.fact_cost_component (
    cost_component_key    VARCHAR(64) PRIMARY KEY,
    product_key           VARCHAR(64) NOT NULL,
    factory_key           VARCHAR(32) NOT NULL,
    cost_type             VARCHAR(32) NOT NULL,  -- material, labor, overhead, tooling
    amount_document_ccy   DECIMAL(18, 4) NOT NULL,
    document_currency     CHAR(3) NOT NULL,
    amount_group_ccy      DECIMAL(18, 4) NOT NULL,
    group_currency        CHAR(3) NOT NULL,
    fx_rate_id            VARCHAR(32),
    cost_version          VARCHAR(16) NOT NULL,
    source_system         VARCHAR(16) NOT NULL,
    effective_date        DATE NOT NULL,
    FOREIGN KEY (product_key) REFERENCES gold_costing.dim_product(product_key)
);

CREATE TABLE IF NOT EXISTS gold_costing.fact_cost_variance (
    variance_key          VARCHAR(64) PRIMARY KEY,
    product_key           VARCHAR(64) NOT NULL,
    factory_key           VARCHAR(32) NOT NULL,
    season_code           VARCHAR(16) NOT NULL,
    should_cost_usd       DECIMAL(18, 4),
    standard_cost_usd     DECIMAL(18, 4),
    actual_cost_usd       DECIMAL(18, 4),
    var_should_std_pct    DECIMAL(10, 6),
    var_std_actual_pct    DECIMAL(10, 6),
    alert_flag            BOOLEAN DEFAULT FALSE,
    as_of_date            DATE NOT NULL
);
