from faker import Faker
import pandas as pd
import random
from pathlib import Path
from datetime import timedelta

def generate_dirty_sales_data(output_path="/tmp/sales_details.csv", products_csv_path="/tmp/prd_info.csv", customers_csv_path="/tmp/cust_info.csv", num_rows=70000):
    fake = Faker()

    # Load Products
    try:
        products_df = pd.read_csv(products_csv_path, parse_dates=["prd_start_dt", "prd_end_dt"]) 
    except Exception:
        products_df = None

    # Load Customers
    try:
        customers_df = pd.read_csv(customers_csv_path)
    except Exception:
        customers_df = None

    # Mapping for Product Keys
    if products_df is not None:
        valid_products = products_df[products_df["prd_end_dt"].isna() & products_df["prd_key"].notna() & (products_df["prd_key"].str.strip() != "")]
        product_keys = valid_products["prd_key"].astype(str).str.strip().tolist()
        price_map = dict(zip(valid_products["prd_key"].astype(str).str.strip(), valid_products.get("prd_cost", pd.Series([None]*len(valid_products)))))
    else:
        product_keys = ["TI-R628", "TT-R982", "PK-7098"]
        price_map = {k: 10 for k in product_keys}

    # Mapping for Customer IDs
    if customers_df is not None:
        cust_pool = customers_df[customers_df["cst_id"].notna()]["cst_id"].tolist()
    else:
        cust_pool = list(range(11000, 40000))

    sales = []
    order_counter = 74882

    while len(sales) < num_rows:
        order_number = f"SO{order_counter}"
        customer_id = random.choice(cust_pool) if cust_pool else None

        order_date = fake.date_between(start_date='-5y', end_date='today')
        ship_date = order_date + timedelta(days=random.randint(1, 10))
        due_date = ship_date + timedelta(days=random.randint(1, 7))

        num_products = random.randint(1, 5)
        if product_keys:
            selected_products = random.sample(product_keys, min(num_products, len(product_keys)))
        else:
            selected_products = []

        for product in selected_products:
            quantity = random.randint(1, 10)
            base_price = price_map.get(product)

            if pd.isna(base_price) or base_price is None:
                base_price = random.randint(5, 200)

            price = int(float(base_price)) + random.randint(-3, 5)
            sales_amount = quantity * price

            # Inject Dirty Data
            if random.random() < 0.02:
                order_dt = 99999999
            else:
                order_dt = int(order_date.strftime("%Y%m%d"))

            if random.random() < 0.02:
                ship_dt = 19000101
            else:
                ship_dt = int(ship_date.strftime("%Y%m%d"))

            if random.random() < 0.02:
                due_dt = 20550101
            else:
                due_dt = int(due_date.strftime("%Y%m%d"))

            if random.random() < 0.03:
                sales_amount *= -1
            if random.random() < 0.03:
                sales_amount = None
            if random.random() < 0.03:
                sales_amount = 0
            if random.random() < 0.02:
                price = -price
            if random.random() < 0.01:
                customer_id = None

            product_key = product
            if random.random() < 0.05:
                product_key = f" {product} "

            sales.append({
                "sls_ord_num": order_number,
                "sls_prd_key": product_key,
                "sls_cust_id": customer_id,
                "sls_order_dt": order_dt,
                "sls_ship_dt": ship_dt,
                "sls_due_dt": due_dt,
                "sls_sales": sales_amount,
                "sls_quantity": quantity,
                "sls_price": price
            })

            if len(sales) >= num_rows:
                break

        order_counter += 1

    df = pd.DataFrame(sales)
    df = df.sample(frac=1).reset_index(drop=True)

    path_obj = Path(output_path)
    path_obj.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(path_obj, index=False)

    print(f"Generated {len(df)} sales records")
    print(f"Saved locally to: {output_path}")

    return df
