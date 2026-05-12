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
schema = "bronze"

BASE_DIR = Path(__file__).resolve().parents[2]
parquet_dir = BASE_DIR / "data/source_erp_parquet"

# Connect to PostgreSQL
conn = psycopg2.connect(
    host=host,
    dbname=dbname,
    user=user,
    password=password
)
cur = conn.cursor()

try:
    files = list(parquet_dir.glob("*.parquet"))

    if not files:
        raise FileNotFoundError(f"No parquet files found in {parquet_dir}")

    for parquet_file in files:
        table_name = f"erp_{parquet_file.stem}".lower()
        print(f"Loading {parquet_file.name} into {schema}.{table_name} ...")

        try:
            df = pd.read_parquet(parquet_file)

            if df.empty:
                print(f"Skipping {table_name} (empty file)")
                continue

            # Create table if not exists (bronze = TEXT columns)
            columns_ddl = ", ".join([f"{col.lower()} TEXT" for col in df.columns])

            cur.execute(sql.SQL("""
                CREATE TABLE IF NOT EXISTS {}.{} ({})
            """).format(
                sql.Identifier(schema),
                sql.Identifier(table_name),
                sql.SQL(columns_ddl)
            ))

            # Insert data (NO TRUNCATE - your logic)
            data_tuples = [tuple(x) for x in df.to_numpy()]
            columns = [col.lower() for col in df.columns]

            insert_query = sql.SQL("""
                INSERT INTO {}.{} ({}) VALUES %s
            """).format(
                sql.Identifier(schema),
                sql.Identifier(table_name),
                sql.SQL(", ").join(map(sql.Identifier, columns))
            )

            execute_values(cur, insert_query, data_tuples)

            print(f"Inserted {len(df)} rows into {schema}.{table_name}")

        except Exception as e:
            conn.rollback()
            print(f"Error loading {parquet_file.name}: {e}")

    conn.commit()

except Exception as e:
    print(f"Fatal error: {e}")

finally:
    cur.close()
    conn.close()

print("All Parquet files processed")