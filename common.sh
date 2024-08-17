source .env

print_info(){
    echo "[INFO]    $1"
}

print_input_message(){
    echo "[INPUT]   $1"
}

# Delete the old pack.
delete_old_pack(){
    print_info "Deleting the old pack if exists."
    rm -r $OLD_PACK_HOME
}

# Unzip the old pack.
extract_old_pack(){
    print_info "Unzipping the old pack."
    unzip $OLD_PACK_HOME.zip -d $PACK_ROOT
}

# Delete the new pack.
delete_new_pack(){
    print_info "Deleting the new pack if exists."
    rm -r $NEW_PACK_HOME
}

# Unzip the new pack.
extract_new_pack(){
    print_info "Unzipping the new pack."
    unzip $NEW_PACK_HOME.zip -d $PACK_ROOT
}

# Create a report file.
create_report_file(){
    print_info "Creating the report file."
    mkdir $OLD_PACK_HOME/report
    touch $OLD_PACK_HOME/report/report.txt
}

# Copy the db driver to old pack.
copy_db_driver_old(){
    local DB_DRIVER_PATH=$1
    print_info "Copying the database driver to the old pack."
    cp $DB_DRIVER_PATH $OLD_PACK_HOME/repository/components/lib
}

# Copy the db driver to old pack.
copy_db_driver_new(){
    local DB_DRIVER_PATH=$1
    print_info "Copying the database driver to the new pack."
    cp $DB_DRIVER_PATH $NEW_PACK_HOME/repository/components/lib
}

# Copy the migration jar and resources to old pack.
copy_migration_resources_to_old(){
    print_info "Copying the migration resources to the old pack."
    cp -r $MIGRATION_RESOURCES_PATH $OLD_PACK_HOME
    print_info "Copying the migration jar to the old pack."
    cp $MIGRATION_JAR_PATH $OLD_PACK_HOME/repository/components/dropins
}

# Copy the migration jar and resources to new pack.
copy_migration_resources_to_new(){
    print_info "Copying the migration jar and resources to the new pack."
    cp -r $MIGRATION_RESOURCES_PATH $NEW_PACK_HOME
    cp $MIGRATION_JAR_PATH $NEW_PACK_HOME/repository/components/dropins
}

# Edit the migration config file.
edit_migration_config(){
    code $MIGRATION_RESOURCES_PATH/migration-config.yml
    print_input_message "Press enter once you edit the file."
    read
}

# Get the update for the pack
get_update(){
    print_info "Getting the update for the pack."
    local PACK_HOME = $1

    sh $PACK_HOME/bin/wso2update_darwin

    print_info "Running the update again to download the updates."
    sh $PACK_HOME/bin/wso2update_darwin
}

# Running the dry run for the old pack.
start_dry_run(){
    print_info "Starting the dry run for the old pack. Press ctrl+c after the dry run is completed."
    sh $OLD_PACK_HOME/bin/wso2server.sh -Dmigrate -Dcomponent=identity -DdryRun
}

# Opening the report file.
open_report_file(){
    print_info "Opening the report file."
    code $OLD_PACK_HOME/report/report.txt
    print_input_message "Press enter after you done checking the report."
    read
}

# Starting the new pack.
start_new_pack(){
    print_info "Starting the new pack. Press ctrl+c after the server starts to continue."
    sh $NEW_PACK_HOME/bin/wso2server.sh
}

# Starting the old pack.
start_old_pack(){
    print_info "Starting the old pack. Press ctrl+c after the server starts to continue."
    sh $OLD_PACK_HOME/bin/wso2server.sh
}

start_migration(){
    print_info "Starting the migration."
    sh $NEW_PACK_HOME/bin/wso2server.sh -Dmigrate -Dcomponent=identity
}

# Delete the old pack toml file.
delete_old_pack_toml(){
    print_info "Deleting the old pack toml file."
    rm $OLD_PACK_HOME/repository/conf/deployment.toml
}

# Copy the toml file from the resources.
copy_old_pack_toml(){
    print_info "Copying the toml file from the resources."
    cp $OLD_PACK_TOML $OLD_PACK_HOME/repository/conf
}

# Delete the new pack toml file.
delete_new_pack_toml(){
    print_info "Deleting the new pack toml file."
    rm $NEW_PACK_HOME/repository/conf/deployment.toml
}

# Copy the toml file from the resources.
copy_new_pack_toml(){
    print_info "Copying the toml file from the resources."
    cp $NEW_PACK_TOML $NEW_PACK_HOME/repository/conf
}

