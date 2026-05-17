from faker import Faker
import pandas as pd
import random
from pathlib import Path

fake = Faker()

NUM_RECORDS = 20000

PROJECT_ROOT = Path(__file__).resolve().parents[2]

OUTPUT_PATH = PROJECT_ROOT / "data/source_erp_parquet/LOC_A101.parquet"

locations = []

country_values = [
    "Australia",
    "US",
    "USA",
    "United States",
    "Canada",
    "Germany",
    "France",
    "UK",
    "DE",
    "",
    " ",
    None
]

# Prefer deriving locations from CRM cst_key values when available
try:
    crm = pd.read_csv("data/source_crm_csv/cust_info.csv")
    crm_keys = crm[crm["cst_key"].notna()]["cst_key"].astype(str).str.strip().tolist()
except Exception:
    crm_keys = []

if crm_keys:
    sample_keys = crm_keys[:NUM_RECORDS]
    for k in sample_keys:
        # Create several realistic CID variants so silver cleaning can exercise transformations
        choice = random.random()
        if choice < 0.60:
            cid = k
        elif choice < 0.80:
            cid = f"AW-{k[2:]}" if k.startswith("AW") else k
        elif choice < 0.90:
            cid = f"NAS{k}"
        else:
            cid = k

        # slight dirty variations
        if random.random() < 0.05:
            cid = cid.replace("-", "")
        if random.random() < 0.05:
            cid = f"  {cid}  "
        if random.random() < 0.03:
            cid = cid.lower()

        cntry = random.choice(country_values)
        if random.random() < 0.03:
            cntry = random.choice(["U.S.", "america", "AUS", "CAN", "unknown", "N/A"])
        if random.random() < 0.03:
            cntry = None

        locations.append({"CID": cid, "CNTRY": cntry})

else:
    # Fallback behaviour
    for i in range(NUM_RECORDS):
        customer_number = 11000 + i
        cid = f"AW-{customer_number:08d}"
        cntry = random.choice(country_values)

        if random.random() < 0.05:
            cid = cid.replace("-", "")
        if random.random() < 0.05:
            cid = f"  {cid}  "
        if random.random() < 0.03:
            cid = cid.lower()

        if random.random() < 0.03:
            cntry = random.choice(["U.S.", "america", "AUS", "CAN", "unknown", "N/A"])
        if random.random() < 0.03:
            cntry = None

        locations.append({"CID": cid, "CNTRY": cntry})

# Create dataframe
df = pd.DataFrame(locations)

# Shuffle rows
df = df.sample(frac=1).reset_index(drop=True)

# Save parquet
OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

df.to_parquet(OUTPUT_PATH, index=False)

print(f"Generated {len(df)} records")
print(f"Saved to: {OUTPUT_PATH}")
