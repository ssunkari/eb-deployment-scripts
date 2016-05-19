#!/bin/bash
ENV_NAME=$1
CNAME=$2
NODE_ENV=$3

config_exists_in_s3 = `eb config list | grep ^"$ENV_NAME"$`

if [[ -z "$config_exists_in_s3" ]; then
	echo "The saved config $ENV_NAME is not uploaded to S3 EB bucket, make sure you run eb config put $ENV_NAME"
	exit 1
fi

eb init rates-query -r eu-west-1 -p "Docker 1.9.1" -k RatePlans
env_status=`aws elasticbeanstalk describe-environments --environment-names $ENV_NAME --region=eu-west-1`

if [[  -z "$env_status" ]]; then
	echo "creating new environment $ENV_NAME"
	eb create $ENV_NAME --cfg "$ENV_NAME" -c "$CNAME" --envvars NODE_ENV=$NODE_ENV -r eu-west-1 --timeout 10
	echo "environment $ENV_NAME created"
	#create environment
else
	echo "updating environment $ENV_NAME, hold your breath for 15 minutes"
	eb config $ENV_NAME --cfg $ENV_NAME
	echo "environment $ENV_NAME updated"
fi

echo "verifying environment $ENV_NAME status"
env_status=`aws elasticbeanstalk describe-environments --environment-names $ENV_NAME --region=eu-west-1`

if [ "$env_status" == "Ready" ]; then
	echo "environment $ENV_NAME is up and ready"
else
	echo "environment $ENV_NAME failed to provision"
	exit 1
fi



