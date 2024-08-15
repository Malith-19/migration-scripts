# Variables
IDENTITY_DB="identity"
SHARED_DB="shared"
POSTGRES_USER="postgres"
OLD_PACK_HOME="/Users/malithd/Documents/repos/product_binaries/wso2is-6.1.0"
NEW_PACK_HOME="/Users/malithd/Documents/repos/product_binaries/wso2is-7.0.0"
DB_DRIVER_PATH="/Users/malithd/Downloads/postgresql-42.7.3.jar"
MIGRATION_JAR_PATH="/Users/malithd/Documents/repos/wso2_enterprise/identity-migration-resources/components/org.wso2.is.migration/migration-service/target/org.wso2.carbon.is.migration-1.0.281-SNAPSHOT.jar"
MIGRATION_RESOURCES_PATH="/Users/malithd/Documents/repos/product_binaries/migration-resources"
NEW_PACK_ROOT="/Users/malithd/Documents/repos/product_binaries"
OLD_PACK_TOML="resources/6.1.0/deployment.toml"
NEW_PACK_TOML="resources/7.0.0/deployment.toml"

# Dropping the identity database.
echo "=== Dropping the identity database. ==="
psql $POSTGRES_USER -c "DROP DATABASE IF EXISTS $IDENTITY_DB;"

# Creating a new identity database.
echo "=== Creating a new identity database. ==="
psql $POSTGRES_USER -c "CREATE DATABASE $IDENTITY_DB;"

# Dropping the shared database.
echo "=== Dropping the shared database. ==="
psql $POSTGRES_USER -c "DROP DATABASE IF EXISTS $SHARED_DB;"

# Creating a new shared database.
echo "=== Creating a new shared database. ==="
psql $POSTGRES_USER -c "CREATE DATABASE $SHARED_DB;"

# Delete the old pack if exists.
echo "=== Deleting the old pack if exists. ==="
rm -r $OLD_PACK_HOME

# Extract the old pack.
echo "=== Extracting the old pack. ==="
unzip $OLD_PACK_HOME.zip -d $NEW_PACK_ROOT

# Create the report file.
echo "=== Create the report file ==="
mkdir $OLD_PACK_HOME/report
touch $OLD_PACK_HOME/report/report.txt

# Executing the SQL scripts.
echo "=== Executing the SQL scripts in shared database. ==="
psql -d $SHARED_DB -f $OLD_PACK_HOME/dbscripts/postgresql.sql

echo "=== Executing the SQL scripts in identity database. ==="
psql -d $IDENTITY_DB -f $OLD_PACK_HOME/dbscripts/identity/postgresql.sql
psql -d $IDENTITY_DB -f $OLD_PACK_HOME/dbscripts/consent/postgresql.sql

# Open the deployment.toml file in the <IS_HOME>/repository/conf directory and configure the database connection details.
# code $OLD_PACK_HOME/repository/conf/deployment.toml
# echo "Press enter after you done the configurations."
# echo "eg:

# [database.identity_db]
# type = "postgre"
# hostname = "localhost"
# name = "identity"
# username = ""
# password = ""
# port = "5432"

# [database.shared_db]
# type = "postgre"
# hostname = "localhost"
# name = "shared"
# username = ""
# password = ""
# port = "5432"
# "
# read

# Delete the old pack toml file.
echo "=== Deleting the old pack toml file. ==="
rm $OLD_PACK_HOME/repository/conf/deployment.toml

# Copy the toml file from the resources.
echo "=== Copying the toml file from the resources. ==="
cp $OLD_PACK_TOML $OLD_PACK_HOME/repository/conf

# Copy the PostgreSQL driver to the <IS_HOME>/repository/components/lib directory.
echo "=== Copying the PostgreSQL driver to the old pack. ==="
cp $DB_DRIVER_PATH $OLD_PACK_HOME/repository/components/lib

# Starting the OLD pack.
echo "=== Starting the OLD pack. ==="
echo "Press ctrl+c after the server starts."
sh $OLD_PACK_HOME/bin/wso2server.sh

# Copy the migration jar to old pack.
echo "=== Copying the migration jar to the old pack. ==="
cp $MIGRATION_JAR_PATH $OLD_PACK_HOME/repository/components/dropins

# Copy the migration resources to old pack.
echo "=== Copying the migration resources to the old pack. ==="
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
unzip $NEW_PACK_HOME.zip -d $NEW_PACK_ROOT

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
# echo "=== Edit the nedeed configurations in the deployment.toml file. by adding or updating below configs. ==="
# echo "Do the following configurations in the deployment.toml file.
# 1. Change the database configurations.

# eg:
# [database.identity_db]
# type = "postgre"
# hostname = "localhost"
# name = "identity"
# username = ""
# password = ""
# port = "5432"

# [database.shared_db]
# type = "postgre"
# hostname = "localhost"
# name = "shared"
# username = ""
# password = ""
# port = "5432"

# 2. Change admin creation permision.

# eg:
# [super_admin]
# ...
# create_admin_account = false

# 3. Add or update the authorization manager properties.

# eg: (Remove tis after migration)
# [authorization_manager.properties]
# GroupAndRoleSeparationEnabled = false

# 4. Add or update below to avoid group_uuid error (don't add this once we fix this in migration).

# [user_store]
# properties.GroupIDEnabled = false
# "

# code $NEW_PACK_HOME/repository/conf/deployment.toml
# echo "Press enter after you done the configurations."
# read

# Copy the toml file from the resources.
echo "=== Copying the toml file from the resources. ==="
cp $NEW_PACK_TOML $NEW_PACK_HOME/repository/conf

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



