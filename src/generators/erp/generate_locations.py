from faker import Faker
import pandas as pd
import random
from pathlib import Path

def generate_dirty_location_data(output_path="/tmp/LOC_A101.parquet", crm_csv_path="/tmp/cust_info.csv", num_records=20000):
    fake = Faker()
    locations = []

    country_values = [
        "Australia", "US", "USA", "United States", "Canada", 
        "Germany", "France", "UK", "DE", "", " ", None
    ]

    try:
        crm = pd.read_csv(crm_csv_path)
        crm_keys = crm[crm["cst_key"].notna()]["cst_key"].astype(str).str.strip().tolist()
    except Exception:
        crm_keys = []

    if crm_keys:
        sample_keys = crm_keys[:num_records]
        for k in sample_keys:
            choice = random.random()
            if choice < 0.60:
                cid = k
            elif choice < 0.80:
                cid = f"AW-{k[2:]}" if k.startswith("AW") else k
            elif choice < 0.90:
                cid = f"NAS{k}"
            else:
                cid = k

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
        for i in range(num_records):
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

    df = pd.DataFrame(locations)
    df = df.sample(frac=1).reset_index(drop=True)

    path_obj = Path(output_path)
    path_obj.parent.mkdir(parents=True, exist_ok=True)
    df.to_parquet(path_obj, index=False)

    print(f"Generated {len(df)} location records")
    print(f"Saved locally to: {output_path}")

    return df
