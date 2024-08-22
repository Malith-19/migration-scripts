#!/bin/bash

# image name: ibmcom/db2
# image run command:
# docker run --platform=linux/amd64 -itd --name 2ec8bf76e622 --privileged=true -p 50000:50000 -e LICENSE=accept -e DB2INST1_PASSWORD=wso2carbon -e DBNAME=identity ibmcom/db2

# Variables.
DB_USERNAME="db2inst1"
DB_PASSWORD="wso2carbon"
CONTAINER_NAME="2ec8bf76e622" # Check this and update the container name.
DB_DRIVER_PATH="/Users/malithd/Downloads/db2jcc4.jar"


source ./common.sh

print_input_message "Please make sure that db2 container is runninng. Once you start the container it needs 10 min to start
properly. Press enter to continue."
read

# Function to configure the DB2 database.
configure_db_database(){
    print_info "Create or recreate the databases"
    print_info "These operations can take a while. Please be patient."
    docker exec -it $CONTAINER_NAME su - db2inst1 -c "db2 force applications all;"

    print_info "Sleeping 1 minute to make sure all the applications are closed"
    sleep 60

    for db_name in "$IDENTITY_DB" "$SHARED_DB"; do
        docker exec -t $CONTAINER_NAME su - db2inst1 -c "db2 drop db $db_name" || true 
        docker exec -t $CONTAINER_NAME su - db2inst1 -c "db2 create database $db_name;"
    done

    print_info "Creating the directories inside the container to copy the dbscripts."
    docker exec $CONTAINER_NAME mkdir -p /tmp/dbscripts/identity
    docker exec $CONTAINER_NAME mkdir -p /tmp/dbscripts/consent

    print_info "Copying the dbscripts to the container."
    docker cp $OLD_PACK_HOME/dbscripts/identity/db2.sql $CONTAINER_NAME:/tmp/dbscripts/identity/db2.sql
    docker cp $OLD_PACK_HOME/dbscripts/consent/db2.sql $CONTAINER_NAME:/tmp/dbscripts/consent/db2.sql
    docker cp $OLD_PACK_HOME/dbscripts/db2.sql $CONTAINER_NAME:/tmp/dbscripts/db2.sql

    print_info "Running the dbscripts inside the container for identity db."
    docker exec -t $CONTAINER_NAME su - db2inst1 -c "db2 connect to $IDENTITY_DB user $DB_USERNAME using \
    $DB_PASSWORD; db2 -td/ -f /tmp/dbscripts/identity/db2.sql -z identity_db2_exec.log; db2 -td/ -f \
    /tmp/dbscripts/consent/db2.sql -z identity_db2_exec.log"

    print_info "Running the dbscripts inside the container for shared db."
    docker exec -t $CONTAINER_NAME su - db2inst1 -c "db2 connect to $SHARED_DB user $DB_USERNAME using \
    $DB_PASSWORD; db2 -td/ -f /tmp/dbscripts/db2.sql -z identity_db2_exec.log;"

    print_info "Finished running the dbscripts"
}

# Remove the old pack and extract the new pack.
delete_old_pack
extract_old_pack

# Configure the database.
configure_db_database

# Copy the toml file to old pack.
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
