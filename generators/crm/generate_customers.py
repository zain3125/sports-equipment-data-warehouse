from faker import Faker
import pandas as pd
import random
from pathlib import Path

fake = Faker()

NUM_RECORDS = 30000
START_ID = 11000
PROJECT_ROOT = Path(__file__).resolve().parents[2]

OUTPUT_PATH = PROJECT_ROOT / "data/source_crm_csv/cust_info.csv"

customers = []
marital_status_values = [
    'S', 'M', 's', 'm',
    ' Single ', 'Married',
    '', None, 'X', 'unknown'
]
gender_values = [
    'M', 'F', 'm', 'f',
    ' Male ', 'Female',
    '', None, 'X', 'unknown'
]

for i in range(NUM_RECORDS):

    # Generate sequential customer ID
    cst_id = START_ID + i

    
    # Generate customer key like original ----> Example: AW00011000
    cst_key = f"AW{cst_id:08d}"

    firstname = fake.first_name()
    lastname = fake.last_name()

    marital_status = random.choice(marital_status_values)
    gender = random.choice(gender_values)

    create_date = fake.date_between(
        start_date='-5y',
        end_date='today'
    )

    
    # Inject dirty data

    # NULL first names
    if random.random() < 0.05:
        firstname = None

    # Leading/trailing spaces
    if random.random() < 0.15:
        firstname = f" {firstname} "

    if random.random() < 0.15:
        lastname = f" {lastname} "

    # Future dates
    if random.random() < 0.03:
        create_date = fake.date_between(
            start_date='+1d',
            end_date='+2y'
        )

    # Duplicate customer IDs
    if random.random() < 0.08 and customers:
        duplicate_customer = random.choice(customers)

        cst_id = duplicate_customer['cst_id']
        cst_key = duplicate_customer['cst_key']

    # Broken customer keys
    if random.random() < 0.03:
        cst_key = ''

    # Invalid customer IDs
    if random.random() < 0.02:
        cst_id = None

    customers.append({
        'cst_id': cst_id,
        'cst_key': cst_key,
        'cst_firstname': firstname,
        'cst_lastname': lastname,
        'cst_marital_status': marital_status,
        'cst_gndr': gender,
        'cst_create_date': create_date
    })


# Create DataFrame
df = pd.DataFrame(customers)

# Shuffle rows
df = df.sample(frac=1).reset_index(drop=True)

# Save CSV
OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
df.to_csv(OUTPUT_PATH, index=False)
print(f"Generated {len(df)} customer records")
print(f"Saved to: {OUTPUT_PATH}")
