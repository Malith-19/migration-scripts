# Purpose
This repository contains the migration scripts for the databases that are used in the migration testing process. The migration scripts are written in bash and the scripts are used to automate the migration process.

If you are implementing migration service with these scripts you can focus on the service implementation and use these scripts to automate the migration process.

# Before run the migration scripts, please make sure you have the following:
- Change the variables section of the script you intend to run.
- Make sure you have the necessary permissions to run the script.
- Create a folder to store toml files and copy the toml files to the folder. (eg: create a resource folder inside the migration scripts folder and copy the toml files to the resource folder)
- Create a .env file by using the .env.example file template.
- Check the relevent bash file for your migration and change the variables section inside the bash file accordingly.

# File structure
- migration-scripts
  - resources
    - toml files
  - db2.sh
  - ..
  - .env
  - README.md

# Common functions
The `common.sh` bash script contains the common functions used in the migration scripts. If you are creating a new migration script for a new database, you can use the functions in the `common.sh` script.

# Contributing
This is a public repository and intension was to make the migration testing process easier. Please feel free to contribute to the repository by creating a pull request.

# Full Article
For more information, please refer to the full article [here](https://medium.com/@malith_dilshan/automating-the-wso2-is-migration-process-94cce2bb80bb)
