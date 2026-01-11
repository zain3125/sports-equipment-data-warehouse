#!/bin/bash
# Variables
DB_NAME="sports_DWH"
DB_SUPERUSER="zain_super"
DB_PASSWORD="password"

# Create Superuser and DB
psql -U postgres -c "CREATE USER $DB_SUPERUSER WITH PASSWORD '$DB_PASSWORD' SUPERUSER;"

psql -U postgres -c "CREATE DATABASE \"$DB_NAME\" OWNER $DB_SUPERUSER;"
