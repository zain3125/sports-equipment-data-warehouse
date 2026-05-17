import pandas as pd
import random
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]

OUTPUT_PATH = PROJECT_ROOT / "source_erp_parquet/PX_CAT_G1V2.parquet"

BASE_CATEGORIES = [
    ("AC_HE", "Accessories", "Helmets"),
    ("CL_JE", "Clothing", "Jerseys"),
    ("CO_RF", "Components", "Road Frames"),
    ("BI_MB", "Bikes", "Mountain Bikes"),
    ("CL_SO", "Clothing", "Socks"),
    ("CL_CA", "Clothing", "Caps"),
    ("AC_BR", "Accessories", "Bike Racks"),
    ("AC_LI", "Accessories", "Lights"),
    ("CO_WH", "Components", "Wheels"),
    ("BI_RB", "Bikes", "Road Bikes"),
]

maintenance_values = [
    "Yes",
    "No"
]

rows = []

for cat_id, cat, subcat in BASE_CATEGORIES:

    row = {
        "id": cat_id,
        "cat": cat,
        "subcat": subcat,
        "maintenance": random.choice(maintenance_values)
    }

    # dirty data injection

    if random.random() < 0.08:
        row["cat"] = f"  {row['cat']}  "

    if random.random() < 0.08:
        row["subcat"] = row["subcat"].upper()

    rows.append(row)

df = pd.DataFrame(rows)

OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

df.to_parquet(OUTPUT_PATH, index=False)

print(f"Generated {len(df)} category rows")
print(f"Saved to: {OUTPUT_PATH}")
