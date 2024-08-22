#!/bin/bash

# Variables.
MSSQL_USER="SA"
MSSQL_PASSWORD="reallyStrongPwd123"
IDENTITY_DB="identity_db"
SHARED_DB="shared_db"
DB_DRIVER_PATH="/Users/malithd/Downloads/sqljdbc_12.4/enu/jars/mssql-jdbc-12.4.2.jre11.jar"
DB_PORT="1433"
CONTAINER_ID="d972e207440f"
MSSQL_JS_SCRIPT="./mssql_configure.js"


set -e

source ./common.sh

# Function to configure the MSSQL database.
configure_mssql_database_arm64() {
    print_info "Configuring MSSQL database."

    print_info "Running on ARM64, setting up databases using Node.js script"
    npm install tedious@14.7.0 --save &&
    npm i async --save &&
    node $MSSQL_JS_SCRIPT "$OLD_PACK_HOME/dbscripts" "$MSSQL_PASSWORD" "$IDENTITY_DB" "$SHARED_DB" "$DB_PORT"
}

# Remove the old pack and extract the new pack.
delete_old_pack
extract_old_pack

# Executing the mssql commands to create the databases.
configure_mssql_database_arm64

# Copying the toml file to old pack.
delete_old_pack_toml
copy_old_pack_toml

# Copy the db driver to old pack.
copy_db_driver_old $DB_DRIVER_PATH

# Start the old pack.
start_old_pack

# Copy the migration jar and resources to old pack.
copy_migration_resources_to_old

# Create the report file.
create_report_file

# Start the dry run.
start_dry_run

# Open the report file.
open_report_file

# Delete the new pack.
delete_new_pack

# Extract the new pack.
extract_new_pack

# Copy the toml file to new pack.
delete_new_pack_toml
copy_new_pack_toml

# Copy the db driver to new pack.
copy_db_driver_new $DB_DRIVER_PATH

# Copy the migration jar and resources to new pack.
copy_migration_resources_to_new

# Run the migration.
start_migration
