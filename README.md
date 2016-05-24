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

## Scripts

### eb_autoscaling.sh
This scripts allows the auto scaling group associated with an environment to be suspended or resumed. This helps with pre-production environments where EC2 instances are automatically shutdown at night/weekends. If the scaling group is not suspended, it will terminate the instance and try to replace it.
To use:
```
./eb_autoscaling.sh suspend/resume <ENV1>,<ENV2>,<ENV3>
```
### eb_create.sh
This script allows environment creation or update. It will apply a saved configuration (from S3) to an evironment.
If the environment already exists it will be updated with the config, if the environment is new, it will be created with the AWS sample app.
To use:
```
./eb_create.sh <APP_NAME> <ENV_NAME> <CNAME>
```
App should now be visible at `http://<CNAME>.eu-west-1.elasticbeanstalk.com`
### eb_build.sh
This script automates the building, tagging, testing, and pushing of a docker container. Once it builds and tags the container with the correct version and remote repository, it will run up the container and execute the `grunt` command within it, it will then push the container to ECR.
To use:
```
./eb_build.sh <GIT_REV> <AWS_ACCOUNT_ID> <APP_NAME> <PROXY_URL> <NO_PROXY> <PORT>
```
The <PORT> value is used to expose the correct port within the Dockerfile.
### eb_publish.sh
This script will publish an application version to the Beanstalk application. It will configure the values in the Dockerrun.aws.json file to point to the correct docker repository/container, and configure the `NODE_ENV` environment variable. It will the create the ZIP file and push it to S3, before instructing Beanstalk to register the version.
To use:
```
./eb_publish.sh <APP_NAME> <GIT_REV> <S3_BUCKET> <AWS_ACCOUNT_ID> <NODE_ENV> <PORT> <BRANCH>
```
The <AWS_ACCOUNT_ID> is the account associated with the ECR repository. The <PORT> is the port that will be mapped in the container I.E the port that the node app is listening on.
### eb_deploy.sh
This script will do an application deployment to the environment. The application should already have been published.
To use:
```
./eb_deploy.sh <APP_NAME> <ENV_NAME> <GIT_REV>
```
### eb_upload.sh
This script will upload the configurations to S3 for use in environment creation or update.
To use:
```
./eb_upload.sh <APP_NAME> <ENV1>,<ENV2>,<ENV3>
```
The configs must be named <ENV>.cfg.yml and be located in sub directory `.elasticbeanstalk/saved_configs`
### eb_publish_prod_artefacts.sh
This script will prepare a prod application based on a dev application
To use:
```
./eb_publish_prod_artefacts.sh <APP_NAME> <GIT_REV> <DEV_ACC_ID> <PROD_ACC_ID> <S3_BUCKET> <PROD_AWS_PROFILE_NAME>
```