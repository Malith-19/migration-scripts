#!/bin/bash

set -e

source ./common.sh

# Delete the old pack if exists.
delete_old_pack

# Extract the old pack.
extract_old_pack

# Starting the old pack.
start_old_pack

# Copy the migration jar file into old pack.
copy_migration_resources_to_old

# Create the report file.
create_report_file

# Edit the migration-config file.
edit_migration_config

# Starting the dry run for the old pack.
start_dry_run

# Opening the report file.
open_report_file

# Delete the new pack if exists.
delete_new_pack

# Unzip a new pack.
extract_new_pack

# Update the new pack before starting.
update_pack $NEW_PACK_HOME

# Starting the new pack.
start_new_pack

# Copy new pack toml.
copy_new_pack_toml

# Copy the migration jar and resources to new pack.
copy_migration_resources_to_new

# Running the migration in the new pack.
start_migration
