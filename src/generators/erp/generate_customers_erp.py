from faker import Faker
import pandas as pd
import random
from pathlib import Path

def generate_dirty_customers_erp_data(output_path="/tmp/CUST_AZ12.parquet", crm_csv_path="/tmp/cust_info.csv", num_records=20000):
    fake = Faker()
    customers = []

    gender_values = [
        "Male", "Female", "M", "F", "male", "female", 
        "M ", "F ", " ", "", None, "Unknown"
    ]

    # Read CRM data
    try:
        crm = pd.read_csv(crm_csv_path)
        crm_keys = crm[crm["cst_key"].notna()]["cst_key"].astype(str).str.strip().tolist()
    except Exception:
        crm_keys = []

    if crm_keys:
        sample_keys = crm_keys[:num_records]
        for k in sample_keys:
            if random.random() < 0.80:
                cid = f"NAS{k}"
            else:
                cid = k

            # Dirty inputs simulation
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
        # Fallback behaviour
        for i in range(num_records):
            customer_number = 11000 + i
            cid = f"NASAW{customer_number:08d}"

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

    df = pd.DataFrame(customers)
    df = df.sample(frac=1).reset_index(drop=True)

    path_obj = Path(output_path)
    path_obj.parent.mkdir(parents=True, exist_ok=True)
    df.to_parquet(path_obj, index=False)

    print(f"Generated {len(df)} ERP customer records")
    print(f"Saved locally to: {output_path}")

    return df
