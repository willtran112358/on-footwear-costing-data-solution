"""Illustrative PLM BOM ingest with idempotent event keys."""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from typing import Any


def bom_line_hash(
    product_key: str,
    component_id: str,
    qty: float,
    uom: str,
    effective_date: str,
) -> str:
    payload = f"{product_key}|{component_id}|{qty}|{uom}|{effective_date}"
    return hashlib.sha256(payload.encode()).hexdigest()


def to_bronze_event(row: dict[str, Any]) -> dict[str, Any]:
    """Wrap a PLM BOM row as a bronze-layer event for Kafka or file landing."""
    now = datetime.now(timezone.utc).isoformat()
    event_id = bom_line_hash(
        product_key=row["product_key"],
        component_id=row["component_id"],
        qty=float(row["qty"]),
        uom=row["uom"],
        effective_date=row["effective_date"],
    )
    return {
        "event_id": event_id,
        "source": "PLM",
        "topic": "costing.plm.bom.v1",
        "ingested_at": now,
        "payload": row,
    }


def main() -> None:
    sample = {
        "product_key": "STYLE01-BLK-42-FW26",
        "component_id": "EVA-MIDSOLE-01",
        "qty": 1.0,
        "uom": "EA",
        "effective_date": "2026-01-15",
        "scrap_rate": 0.02,
    }
    event = to_bronze_event(sample)
    print(json.dumps(event, indent=2))


if __name__ == "__main__":
    main()
