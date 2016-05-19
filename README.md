# rates-eb-scripts
Various automation scripts for elastic beanstalk and docker. 
Elastic Beanstalk environment files for rates applications.

## Config files
Config files are located in the correct folder structure for the EB CLI to locate. These are not automated so need to be uploaded to S3 manualy when a change is made.

To use, first init eb cli with correct application:
```
eb init <APP_NAME> -r eu-west-1
```
Then we can list the configs currently on the server:
```
eb config list
```
To get a config file from the server:
```
eb config get <CONFIG_NAME>
```
You can then make the required changes to the local copy, commit to repo, and push back the server:
```
eb config put <CONFIG_NAME>
```
**N.B pushing the config to S3 will not trigger an environment update**
