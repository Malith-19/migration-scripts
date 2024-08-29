#! /bin/bash

set -e

source ./common.sh

print_info "Since we are using docker container for the oracle, you need to create the database and execute the db scripts 
manually."

# Variables.
DB_DRIVER_PATH="/Users/malithd/Downloads/ojdbc11.jar"

# Delete the old pack.
delete_old_pack

# Extract the old pack.
extract_old_pack

# Create the report file.
create_report_file

# Copy the Oracle driver to the <IS_HOME>/repository/components/lib directory.
copy_db_driver_old $DB_DRIVER_PATH

# Copy the old pack toml file from the resources.
delete_old_pack_toml
copy_old_pack_toml


# Starting the old pack.
start_old_pack

# Copy the migration jar and resources to old pack.
copy_migration_resources_to_old

# Start the dry run
start_dry_run

# Open the report file.
open_report_file

# Delete the new pack.
delete_new_pack

# Extract the new pack.
extract_new_pack

# Replace the toml file in the new pack.
delete_new_pack_toml
copy_new_pack_toml

# Copy the Oracle driver to the <IS_HOME>/repository/components/lib directory.
copy_db_driver_new $DB_DRIVER_PATH

# Copy the migration jar and resources to new pack.
copy_migration_resources_to_new

# Run the migration.
start_migration
