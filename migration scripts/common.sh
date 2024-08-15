source .env

print_info(){
    echo "[INFO]    $1"
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

# Copy the db driver to old pack.
copy_db_driver(){
    local DB_DRIVER_PATH=$1
    print_info "Copying the MySQL driver to the old pack."
    cp $DB_DRIVER_PATH $OLD_PACK_HOME/repository/components/lib
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

