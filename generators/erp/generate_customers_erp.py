from faker import Faker
import pandas as pd
import random
from pathlib import Path
from datetime import date

fake = Faker()

NUM_RECORDS = 20000

PROJECT_ROOT = Path(__file__).resolve().parents[2]

OUTPUT_PATH = PROJECT_ROOT / "data/source_erp_parquet/CUST_AZ12.parquet"

customers = []

gender_values = [
    "Male",
    "Female",
    "M",
    "F",
    "male",
    "female",
    "M ",
    "F ",
    " ",
    "",
    None,
    "Unknown"
]

# If CRM customers exist, derive ERP CIDs from the canonical cst_key values
try:
    crm = pd.read_csv("data/source_crm_csv/cust_info.csv")
    crm_keys = crm[crm["cst_key"].notna()]["cst_key"].astype(str).str.strip().tolist()
except Exception:
    crm_keys = []

if crm_keys:
    sample_keys = crm_keys[:NUM_RECORDS]
    for k in sample_keys:
        # randomly add NAS prefix or leave as-is to simulate dirty data
        if random.random() < 0.80:
            cid = f"NAS{k}"
        else:
            cid = k

        # small variations to simulate dirty inputs
        if random.random() < 0.03:
            cid = cid.replace("NAS", "")
        if random.random() < 0.03:
            cid = f"  {cid}  "
        if random.random() < 0.02:
            cid = cid.lower()

        bdate = fake.date_of_birth(minimum_age=18, maximum_age=75)
        if random.random() < 0.02:
            bdate = fake.date_between(start_date='+1d', end_date='+3y')
        if random.random() < 0.03:
            bdate = None

        gen = random.choice(gender_values)

        customers.append({"CID": cid, "BDATE": bdate, "GEN": gen})

else:
    # fallback behaviour when CRM file not present: generate sequential NASAW ids
    for i in range(NUM_RECORDS):
        customer_number = 11000 + i
        cid = f"NASAW{customer_number:08d}"

        # Inject dirty variations
        if random.random() < 0.03:
            cid = cid.replace("NAS", "")
        if random.random() < 0.03:
            cid = f"  {cid}  "
        if random.random() < 0.02:
            cid = cid.lower()

        bdate = fake.date_of_birth(minimum_age=18, maximum_age=75)
        if random.random() < 0.02:
            bdate = fake.date_between(start_date='+1d', end_date='+3y')
        if random.random() < 0.03:
            bdate = None

        gen = random.choice(gender_values)

        customers.append({"CID": cid, "BDATE": bdate, "GEN": gen})

# Create dataframe
df = pd.DataFrame(customers)

# Shuffle rows
df = df.sample(frac=1).reset_index(drop=True)

# Save parquet
OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

df.to_parquet(OUTPUT_PATH, index=False)

print(f"Generated {len(df)} records")
print(f"Saved to: {OUTPUT_PATH}")
