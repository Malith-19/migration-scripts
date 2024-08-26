#!/bin/bash

source ./common.sh

set -e

# Variables
MYSQL_USER="root"
MYSQL_HOST="localhost"
MYSQL_PASSWORD="Malith-21512"
CHARSET="latin1"
COLLATION="latin1_swedish_ci"
DB_DRIVER_PATH="/Users/malithd/Downloads/mysql-connector-j-8.0.33/mysql-connector-j-8.0.33.jar"

# Execute multiple MySQL commands
print_info "Creating the databases and tables in the MySQL server."

mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -h $MYSQL_HOST<<EOF
DROP DATABASE IF EXISTS $IDENTITY_DB;
CREATE DATABASE $IDENTITY_DB CHARACTER SET $CHARSET COLLATE $COLLATION;
DROP DATABASE IF EXISTS $SHARED_DB;
CREATE DATABASE $SHARED_DB CHARACTER SET $CHARSET COLLATE $COLLATION;
USE $IDENTITY_DB;
SOURCE $OLD_PACK_HOME/dbscripts/identity/mysql.sql;
SOURCE $OLD_PACK_HOME/dbscripts/consent/mysql.sql;
USE $SHARED_DB;
SOURCE $OLD_PACK_HOME/dbscripts/mysql.sql;
EOF

# Remove the old pack and extract new pack.
delete_old_pack
extract_old_pack

# Copy the toml file to old pack.
copy_old_pack_toml

# Copy the MySQL driver to the old pack.
copy_db_driver_old $DB_DRIVER_PATH

# Create the report file.
create_report_file

# Copy the migration jar and resources to the old pack.
copy_migration_resources_to_old

# Start the old pack.
start_old_pack

# Start the dry run.
start_dry_run

# Open the report file.
open_report_file

# Remove the new pack and extract the new pack.
delete_new_pack
extract_new_pack

# Copy the toml file to new pack.
copy_new_pack_toml

# Copy the MySQL driver to the new pack.
copy_db_driver_new $DB_DRIVER_PATH

# Copy the migration jar and resources to the new pack.
copy_migration_resources_to_new

# Start migration.
start_migration
