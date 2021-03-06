# DynamoDB-Database-Refresh
## Information
Contains files needed to refresh the DynamoDB database.

Utilised a npm package:
 - [copy-dynamodb-table](https://www.npmjs.com/package/copy-dynamodb-table)

This is designed to run on TeamCity as a build job.

>**NOTE:** This will delete the table before you copy over new information, all old information will be lost. This functionality can be changed in the future.

## Limitations
- Existing table is deleted before copy. Again, this can be removed or changed to be optional, but it is not needed at the moment

## Running on Teamcity

### Pre-requisites
#### Keys
You will need to create an AWS IAM user in each account that you have the DynamoDB tables in. They will need to have policies attached that will allow full access to DynamoDB resources. Then you need to create some programmatic access keys to pass into TeamCity.

Name the IAM user something specific to the use e.g. PROOJECTX-dynbamodb-refresh

### How to use
To run on Teamcity, add this repo as a VCS root.

You will need to add some environment variables to allow the build to work correctly:

|Item | Variable name|
|-----|--------------|
|AWS access key ID for source account (copy from)|SOURCE_AWS_KEY| 
|AWS secret key for source account (copy from)| SOURCE_SECRET_KEY|
|AWS region to copy table to|SOURCE_REGION|
|Name of the table to copy from|SOURCE_TABLE_NAME|
|See above (copy to)|DESTINATION_AWS_KEY|
|See above (copy to)|DESTINATION_SECRET_KEY|
|AWS region to copy table to|DESTINATION_REGION|
|Name of the table to copy to|DESTINATION_TABLE_NAME|

>**NOTE:** If the destination table name is an existing table, it will delete it first, then copy. 

The [docker-build](docker-build.sh) script needs to be run in the build step.
>**NOTE:** You may have to make the script executable with 
```
chmod +x <PATH_TO_BUILD_SCRIPT>
```
>**NOTE:** You may have to specify path to shell to execute the script
```
/bin/bash <PATH_TO_BUILD_SCRIPT>
```

