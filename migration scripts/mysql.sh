#!/bin/bash

source ./common.sh

# Variables.
MYSQL_USER="root"
MYSQL_HOST="localhost"
MYSQL_PASSWORD="Malith-21512"
IDENTITY_DB="identity"
SHARED_DB="shared"
CHARSET="latin1"
COLLATION="latin1_swedish_ci"
DB_DRIVER_PATH="/Users/malithd/Downloads/mysql-connector-j-8.0.33/mysql-connector-j-8.0.33.jar"

# Execute multiple MySQL commands.
echo "=== Creating the databases and tables in the MySQL server ==="
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -h $MYSQL_HOST <<EOF
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

if [ $? -eq 0 ]; then
  echo "Dropped and created databases successfully."
  echo "Executed the SQL scripts successfully."
else
  echo "Failed to manage databases."
  exit 1
fi

# Delete the old pack if exists.
delete_old_pack

# Extract the old pack.
extract_old_pack

# Create the report file.
create_report_file

# Copy the MySQL driver to the <IS_HOME>/repository/components/lib directory.
copy_db_driver $DB_DRIVER_PATH

# Open the deployment.toml file in the <IS_HOME>/repository/conf directory and configure the database connection details.
echo "=== Edit the nedeed configurations in the deployment.toml file. by adding or updating below configs. ==="
echo "[database.identity_db]
type = "mysql"
hostname = "localhost"
name = $IDENTITY_DB
username = $MYSQL_USER
password = $MYSQL_PASSWORD
port = "3306"

[database.shared_db]
type = "mysql"
hostname = "localhost"
name = $SHARED_DB
username = $MYSQL_USER
password = $MYSQL_PASSWORD
port = "3306"
"


# Open the deployment.toml file in the <IS_HOME>/repository/conf directory and configure the database connection details.
code $OLD_PACK_HOME/repository/conf/deployment.toml
echo "Press enter after you done the configurations."
read

# Starting the old pack.
echo "=== Starting the old pack. ==="
echo "Please press ctrl+c after you created a group in using the console."
# sh $OLD_PACK_HOME/bin/wso2server.sh

# Copy the migration jar file into old pack.
echo "=== Copying the migration jar to the old pack ==="
cp $MIGRATION_JAR_PATH $OLD_PACK_HOME/repository/components/dropins
echo "Migration jar copied successfully."

# Edit the migration-config file.
echo "=== Edit the migration-config file ==="
echo "Please add the current version and migration version."
echo "Please add the reportPath s by creating a txt file where you want."
echo "Press enter after you done the configurations."
code $MIGRATION_RESOURCES_PATH/migration-config.yaml
read
echo "Migration configurations have done."

# Copy the migration resources folder into old pack.
echo "=== Copying the migration resources to old pack ==="
cp -r $MIGRATION_RESOURCES_PATH $OLD_PACK_HOME
echo "Migration resource folder has copied to old pack home."

# Starting the dry run for the old pack.
echo "=== Starting the dry run for the old pack. ==="
echo "Press ctrl+c after the dry run is completed."
sh $OLD_PACK_HOME/bin/wso2server.sh -Dmigrate -Dcomponent=identity -DdryRun

# Opening the report file.
echo "Opening the report file. Please check the report for any errors."
code $OLD_PACK_HOME/report/report.txt
echo "Press enter after you done checking the report."
read



# Delete the new pack if exists.
echo "=== Deleting the new pack if exists. ==="
rm -r $NEW_PACK_HOME

# Unzip a new pack.
echo "=== Unzipping the new pack. ==="
unzip $NEW_PACK_ZIP -d $NEW_PACK_ROOT

# Update the new pack before starting.
echo "=== Running the update script in new pack to check for updates. ==="
# $NEW_PACK_HOME/bin/wso2update_darwin

echo "=== Running the update script in new pack to get the updates ==="
# $NEW_PACK_HOME/bin/wso2update_darwin

# Starting the new pack.
echo "=== Starting the new pack. ==="
echo "Please press ctrl+c aftre verifying the start up."
# sh $NEW_PACK_HOME/bin/wso2server.sh

# Configuring the toml file in the new pack.
echo "=== Edit the nedeed configurations in the deployment.toml file. by adding or updating below configs. ==="
echo "Do the following configurations in the deployment.toml file.
1. Change the database configurations.

eg:
[database.identity_db]
type = "mysql"
hostname = "localhost"
name = "regdb"
username = "regadmin"
password = "regadmin"
port = "3306"

[database.shared_db]
type = "mysql"
hostname = "localhost"
name = "regdb"
username = "regadmin"
password = "regadmin"
port = "3306"

2. Change admin creation permision.

eg:
[super_admin]
...
create_admin_account = false

3. Add or update the authorization manager properties.

eg: (Remove tis after migration)
[authorization_manager.properties]
GroupAndRoleSeparationEnabled = false

4. Add or update below to avoid group_uuid error (don't add this once we fix this in migration).

[user_store]
properties.GroupIDEnabled = false
"
code $NEW_PACK_HOME/repository/conf/deployment.toml
echo "Press enter after you done the configurations."
read

# Copy the database driver to the new pack.
echo "=== Copying the mysql jar to the new pack ==="
cp $DB_DRIVER_PATH $NEW_PACK_HOME/repository/components/lib

# Copy the migration jar file into new pack.
echo "=== Copying the migration jar to the new pack ==="
cp $MIGRATION_JAR_PATH $NEW_PACK_HOME/repository/components/dropins

# Copy the migration resources folder into new pack.
echo "=== Copying the migration resources to new pack ==="
cp -r $MIGRATION_RESOURCES_PATH $NEW_PACK_HOME

# Running the migration in the new pack.
echo "=== Running the migration in the new pack. ==="
sh $NEW_PACK_HOME/bin/wso2server.sh -Dmigrate -Dcomponent=identity
