import pandas as pd
import psycopg2
from psycopg2 import sql
from psycopg2.extras import execute_values
from pathlib import Path

# Constants
host = "localhost"
dbname = "sports_DWH"
user = "zain_super"
password = "password"
schema = "bronz"
parquet_dir = Path("/mnt/ssd/sports-equipment-data-warehouse/data/source_erp_parquet/")

# Connect to PostgreSQL
conn = psycopg2.connect(f"host={host} dbname={dbname} user={user} password={password}")
cur = conn.cursor()

# Loop over all Parquet files in folder
for parquet_file in parquet_dir.glob("*.parquet"):
    table_name = f"erp_{parquet_file.stem}".lower()
    print(f"Loading {parquet_file.name} into {schema}.{table_name} ...")

    df = pd.read_parquet(parquet_file)
    if df.empty:
        print(f"Skipping {table_name} (empty file)")
        continue

    cur.execute(sql.SQL("TRUNCATE TABLE {}.{}").format(
        sql.Identifier(schema),
        sql.Identifier(table_name)
    ))

    # Insert DataFrame into Postgres
    data_tuples = [tuple(x) for x in df.to_numpy()]
    columns = [col.lower() for col in df.columns]
    insert_query = sql.SQL("INSERT INTO {}.{} ({}) VALUES %s").format(
        sql.Identifier(schema),
        sql.Identifier(table_name),
        sql.SQL(", ").join(map(sql.Identifier, columns))
    )
    execute_values(cur, insert_query, data_tuples)
    print(f"Inserted {len(df)} rows into {schema}.{table_name}")

conn.commit()
cur.close()
conn.close()
print("All Parquet files loaded successfully!")
