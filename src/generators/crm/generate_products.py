from faker import Faker
import pandas as pd
import random
from pathlib import Path
from datetime import timedelta

def generate_dirty_product_data(output_path="/tmp/prd_info.csv", num_products=500, start_prd_id=210):
    fake = Faker()
    products = []

    # Canonical categories
    CATEGORIES = [
        ("AC_HE", "Accessories", "Helmets"),
        ("CL_JE", "Clothing", "Jerseys"),
        ("CO_RF", "Components", "Road Frames"),
        ("BI_MB", "Bikes", "Mountain Bikes"),
        ("CL_SO", "Clothing", "Socks"),
        ("CL_CA", "Clothing", "Caps")
    ]

    NAME_MAP = {
        "CO_RF": {"name": "HL Road Frame", "variants": ["Black", "Red", "Silver"], "sizes": ["52", "54", "56", "58", "60", "62"], "line": "R"},
        "AC_HE": {"name": "Sport-100 Helmet", "variants": ["Black", "Blue", "Red"], "sizes": [], "line": "S"},
        "CL_JE": {"name": "Long-Sleeve Logo Jersey", "variants": [], "sizes": ["S", "M", "L", "XL"], "line": "S"},
        "CL_SO": {"name": "Mountain Bike Socks", "variants": [], "sizes": ["M", "L"], "line": "M"},
        "CL_CA": {"name": "AWC Logo Cap", "variants": [], "sizes": [], "line": "S"},
        "BI_MB": {"name": "Trail Master Mountain Bike", "variants": ["Red", "Black"], "sizes": ["S", "M", "L"], "line": "M"}
    }

    def random_cost():
        if random.random() < 0.05:
            return None
        if random.random() < 0.03:
            return -random.randint(1, 100)
        return round(random.uniform(3, 2000), 2)

    def random_line(valid_line):
        values = [valid_line, valid_line.lower(), f"{valid_line} ", "", None, "X", "unknown"]
        weights = [70, 5, 5, 5, 5, 5, 5]
        return random.choices(values, weights=weights)[0]

    for i in range(num_products):
        cat_id, cat, subcat = random.choice(CATEGORIES)
        prd_id = start_prd_id + i
        meta = NAME_MAP.get(cat_id, {})

        variant = random.choice(meta.get("variants", [])) if meta.get("variants") else ""
        size = random.choice(meta.get("sizes", [])) if meta.get("sizes") else ""

        prefix = cat_id.replace("_", "-")
        family = fake.lexify(text="??").upper()
        model = fake.bothify(text="?###").upper()

        prd_key = f"{prefix}-{family}-{model}"
        if size:
            prd_key += f"-{size}"

        prd_nm = meta.get("name", "Product")
        if variant:
            prd_nm += f" - {variant}"
        if size:
            prd_nm += f" - {size}"

        prd_cost = random_cost()
        prd_line = random_line(meta.get("line", "X"))

        start_dt = fake.date_between(start_date='-15y', end_date='-1y')
        end_dt = None
        if random.random() < 0.40:
            end_dt = start_dt + timedelta(days=random.randint(100, 2000))

        # Dirty data injection
        if random.random() < 0.10:
            prd_nm = f" {prd_nm} "

        if random.random() < 0.05 and products:
            duplicate = random.choice(products)
            prd_id = duplicate["prd_id"]

        if random.random() < 0.03:
            prd_key = ""

        if random.random() < 0.02:
            start_dt = fake.date_between(start_date='+1y', end_date='+5y')

        products.append({
            "prd_id": prd_id,
            "prd_key": prd_key,
            "prd_nm": prd_nm,
            "prd_cost": prd_cost,
            "prd_line": prd_line,
            "prd_start_dt": start_dt,
            "prd_end_dt": end_dt
        })

    df = pd.DataFrame(products)
    df = df.sample(frac=1).reset_index(drop=True)

    path_obj = Path(output_path)
    path_obj.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(path_obj, index=False)

    print(f"Generated {len(df)} product records")
    print(f"Saved locally to: {output_path}")

    return df
