from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    "owner": "zain",
}

with DAG(
    dag_id="sports_equipment_pipeline",
    start_date=datetime(2025, 1, 1),
    schedule="@daily",
    catchup=False,
    default_args=default_args,
) as dag:

    # =========================================
    # GENERATORS
    # =========================================

    generate_customers = BashOperator(
        task_id="generate_customers",
        bash_command="python /opt/project/generators/crm/generate_customers.py",
    )

    generate_products = BashOperator(
        task_id="generate_products",
        bash_command="python /opt/project/generators/crm/generate_products.py",
    )

    generate_sales = BashOperator(
        task_id="generate_sales",
        bash_command="python /opt/project/generators/crm/generate_sales.py",
    )

    generate_erp_customers = BashOperator(
        task_id="generate_erp_customers",
        bash_command="python /opt/project/generators/erp/generate_customers_erp.py",
    )

    generate_locations = BashOperator(
        task_id="generate_locations",
        bash_command="python /opt/project/generators/erp/generate_locations.py",
    )

    generate_categories = BashOperator(
        task_id="generate_categories",
        bash_command="python /opt/project/generators/erp/generate_categories.py",
    )

    # =========================================
    # ORDER
    # =========================================

    [
        generate_customers,
        generate_products,
        generate_erp_customers,
        generate_locations,
        generate_categories,
    ] >> generate_sales