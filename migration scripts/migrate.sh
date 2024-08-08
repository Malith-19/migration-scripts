#!/bin/bash

# Variables.
MYSQL_USER="root"
MYSQL_HOST="localhost"
MYSQL_PASSWORD="Malith-21512"
IDENTITY_DB="identity"
SHARED_DB="shared"
CHARSET="latin1"
COLLATION="latin1_swedish_ci"
OLD_PACK_HOME="/Users/malithd/Documents/repos/product_binaries/wso2is-6.1.0"
DB_DRIVER_PATH="/Users/malithd/Downloads/mysql-connector-j-8.0.33/mysql-connector-j-8.0.33.jar"

echo "=== Creating the databases and tables in the MySQL server ==="

# Execute multiple MySQL commands.
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

echo "=== Copying the mysql jar to the old pack ==="
# Copy the MySQL driver to the <IS_HOME>/repository/components/lib directory.
cp $DB_DRIVER_PATH $OLD_PACK_HOME/repository/components/lib

if [ $? -eq 0 ]; then
  echo "MySQL driver copied successfully."
else
  echo "Failed to copy the MySQL driver."
  exit 1
fi

# Open the deployment.toml file in the <IS_HOME>/repository/conf directory and configure the database connection details.
echo "=== Edit the nedeed configurations in the deployment.toml file. by adding or updating below configs. ==="
echo "[database.identity_db]
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
port = "3306""


# Open the deployment.toml file in the <IS_HOME>/repository/conf directory and configure the database connection details.
code $OLD_PACK_HOME/repository/conf/deployment.toml
echo "Press enter after you done the configurations."
read

# Starting the old pack.
echo "=== Starting the old pack. ==="
sh $OLD_PACK_HOME/bin/wso2server.sh



