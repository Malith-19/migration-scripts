#!/bin/bash

# Variables
MYSQL_USER="root"
MYSQL_HOST="localhost"
MYSQL_PASSWORD="Malith-21512"
IDENTITY_DB="identity"
SHARED_DB="shared"
CHARSET="latin1"
COLLATION="latin1_swedish_ci"
OLD_PACK_HOME="/Users/malithd/Documents/repos/product binaries/wso2is-6.1.0"
DB_DRIVER_PATH="/Users/malithd/Downloads/mysql-connector-j-8.0.33/mysql-connector-j-8.0.33.jar"

# Prompt for the password
# echo -n "Enter MySQL password: "
# read -s MYSQL_PASSWORD
# echo

# Execute multiple MySQL commands
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -h $MYSQL_HOST <<EOF
DROP DATABASE IF EXISTS $IDENTITY_DB;
CREATE DATABASE $IDENTITY_DATABASE CHARACTER SET $CHARSET COLLATE $COLLATION;
DROP DATABASE IF EXISTS $SHARED_DB;
CREATE DATABASE $SHARED_DB CHARACTER SET $CHARSET COLLATE $COLLATION;
USE $IDENTITY_DB;
SOURCE $OLD_PACK_HOME/dbscripts/identity/mysql.sql;
SOURCE $OLD_PACK_HOME/dbscripts/consent/mysql.sql;
USE $SHARED_DB;
SOURCE $OLD_PACK_HOME/dbscripts/mysql.sql;
EOF

if [ $? -eq 0 ]; then
  echo "Database '$OLD_DATABASE' dropped and '$NEW_DATABASE' created successfully."
else
  echo "Failed to manage databases."
  exit 1
fi

# Copy the MySQL driver to the <IS_HOME>/repository/components/lib directory
cp $DB_DRIVER_PATH $OLD_PACK_HOME/repository/components/lib

if [ $? -eq 0 ]; then
  echo "MySQL driver copied successfully."
else
  echo "Failed to copy the MySQL driver."
  exit 1
fi

# Open the deployment.toml file in the <IS_HOME>/repository/conf directory and configure the database connection details.
echo "Edit the nedeed configurations in the deployment.toml file. by adding or updating below configs."

code $OLD_PACK_HOME/repository/conf/deployment.toml

# Starting the old pack.


