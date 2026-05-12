#!/bin/bash

DB_NAME="sports_DWH"
DB_SUPERUSER="zain_super"
DB_PASSWORD="password"

echo "Starting database setup..."

echo "Checking/Creating PostgreSQL user..."
sudo -u postgres psql <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB_SUPERUSER') THEN
      CREATE USER $DB_SUPERUSER WITH PASSWORD '$DB_PASSWORD' SUPERUSER;
   END IF;
END
\$\$;
EOF

echo "User check/creation done"

echo "Checking/Creating database..."
sudo -u postgres psql <<EOF
SELECT 'CREATE DATABASE $DB_NAME'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\gexec
EOF

echo "Database ready"

REPO_DIR="$(git rev-parse --show-toplevel)"

echo "Copying CRM CSV files..."
sudo mkdir -p /var/lib/postgresql/crm_data

sudo cp -r "$REPO_DIR/data/source_crm_csv/"* \
/var/lib/postgresql/crm_data/

echo "Files copied successfully"

sudo chown -R postgres:postgres /var/lib/postgresql/crm_data
sudo chmod -R 755 /var/lib/postgresql/crm_data

echo "Permissions fixed"

echo "Setup completed successfully"
