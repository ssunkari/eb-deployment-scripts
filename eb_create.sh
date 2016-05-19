#!/bin/bash
EB_APP_NAME=$1
ENV_NAME=$2
CNAME=$3

eb init "$EB_APP_NAME" -r eu-west-1

config_exists_in_s3=`eb config list | grep ^"$ENV_NAME"$`

sudo sed -i "s/sc: git/sc: null/" .elasticbeanstalk/config.yml

if [[ -z "$config_exists_in_s3" ]]; then
	echo "The saved config $ENV_NAME is not uploaded to S3 EB bucket, make sure you run eb config put $ENV_NAME"
	exit 1
fi

env_status=`aws elasticbeanstalk describe-environments --environment-names $ENV_NAME --region=eu-west-1 --output text --no-include-deleted`

if [[ -z "$env_status" ]]; then
	echo "creating new environment $ENV_NAME"
	eb create $ENV_NAME --cfg "$ENV_NAME" -c "$CNAME" -r eu-west-1 --timeout 30 -v --sample
	echo "environment $ENV_NAME created"
	#create environment
else
	echo "updating environment $ENV_NAME, hold your breath for atleast 20 minutes"
	eb config $ENV_NAME --cfg $ENV_NAME --timeout 30 -v
	echo "environment $ENV_NAME updated"
fi

echo "verifying environment $ENV_NAME status"
env_status=`aws elasticbeanstalk describe-environments --environment-names $ENV_NAME --region=eu-west-1 --output text --no-include-deleted`

if [ "$env_status" == "Ready" ]; then
	echo "environment $ENV_NAME is up and ready"
else
	echo "environment $ENV_NAME failed to provision"
	exit 1
fi




