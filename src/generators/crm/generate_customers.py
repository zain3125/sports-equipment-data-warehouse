from faker import Faker
import pandas as pd
import random
from pathlib import Path

def generate_dirty_customer_data(output_path="/tmp/cust_info.csv", num_records=30000, start_id=11000):
    fake = Faker()
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

    for i in range(num_records):
        cst_id = start_id + i
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
        if random.random() < 0.05:
            firstname = None

        if random.random() < 0.15:
            firstname = f" {firstname} "

        if random.random() < 0.15:
            lastname = f" {lastname} "

        if random.random() < 0.03:
            create_date = fake.date_between(
                start_date='+1d',
                end_date='+2y'
            )

        if random.random() < 0.08 and customers:
            duplicate_customer = random.choice(customers)
            cst_id = duplicate_customer['cst_id']
            cst_key = duplicate_customer['cst_key']

        if random.random() < 0.03:
            cst_key = ''

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

    # Make sure dir is exists before saving
    path_obj = Path(output_path)
    path_obj.parent.mkdir(parents=True, exist_ok=True)

    # Save Locally
    df.to_csv(output_path, index=False)

    print(f"Generated {len(df)} customer records")
    print(f"Saved locally to: {output_path}")

    return df
