"""Should-cost vs standard vs actual reconciliation on synthetic footwear SKUs."""

from __future__ import annotations

from pathlib import Path

import pandas as pd

THRESHOLD_PCT = 0.05
DATA_PATH = Path(__file__).resolve().parent.parent / "data" / "sample_costing.csv"


def load_data(path: Path = DATA_PATH) -> pd.DataFrame:
  if path.exists():
    return pd.read_csv(path)
  return pd.DataFrame(
    [
      {"sku": "PERF-01-BLK-42", "season": "FW26", "should": 28.40, "standard": 29.10, "actual": 30.25},
      {"sku": "PERF-01-BLK-43", "season": "FW26", "should": 28.40, "standard": 28.95, "actual": 29.00},
      {"sku": "LIFE-02-WHT-44", "season": "FW26", "should": 42.00, "standard": 41.50, "actual": 44.80},
    ]
  )


def enrich_variance(df: pd.DataFrame) -> pd.DataFrame:
  out = df.copy()
  out["var_should_std_pct"] = (out["standard"] - out["should"]) / out["should"]
  out["var_std_actual_pct"] = (out["actual"] - out["standard"]) / out["standard"]
  out["alert"] = out["var_std_actual_pct"].abs() > THRESHOLD_PCT
  out["driver_hint"] = out.apply(_driver_hint, axis=1)
  return out


def _driver_hint(row: pd.Series) -> str:
  if row["var_std_actual_pct"] > THRESHOLD_PCT:
    return "Investigate: material price / FX / freight / yield"
  if row["var_should_std_pct"] > THRESHOLD_PCT:
    return "Investigate: BOM change after should-cost lock"
  return "Within tolerance"


def main() -> None:
  result = enrich_variance(load_data())
  print(result.to_string(index=False))
  alerts = int(result["alert"].sum())
  print(f"\nAlerts: {alerts} / {len(result)} SKUs")


if __name__ == "__main__":
  main()
