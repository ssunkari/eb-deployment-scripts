#!/bin/bash
EB_APP_NAME=$1
EB_ENV_NAME=$2
CNAME=$3

echo "Fix Env name"
sudo sed -i "s/<ENV>/$EB_EB_ENV_NAME/" .elasticbeanstalk/config.yml
echo "Fix App name"
sudo sed -i "s/<APP>/$EB_APP_NAME/" .elasticbeanstalk/config.yml
echo "Fix sc"
sudo sed -i "s/sc: git/sc: null/" .elasticbeanstalk/config.yml

config_exists_in_s3=`eb config list | grep ^"$EB_ENV_NAME"$`

if [[ -z "$config_exists_in_s3" ]]; then
	echo "The saved config $EB_ENV_NAME is not uploaded to S3 EB bucket, make sure you run eb config put $EB_ENV_NAME"
	exit 1
fi

env_status=`aws elasticbeanstalk describe-environments --environment-names $EB_ENV_NAME --region=eu-west-1 --output text --no-include-deleted`

if [[ -z "$env_status" ]]; then
	echo "creating new environment $EB_ENV_NAME"
	eb create $EB_ENV_NAME --cfg "$EB_ENV_NAME" -c "$CNAME" -r eu-west-1 --timeout 30 -v --sample
	echo "environment $EB_ENV_NAME created"
	#create environment
else
	echo "updating environment $EB_ENV_NAME, hold your breath for atleast 20 minutes"
	eb config $EB_ENV_NAME --cfg $EB_ENV_NAME --timeout 30 -v
	echo "environment $EB_ENV_NAME updated"
fi

echo "verifying environment $EB_ENV_NAME status"
env_status=`aws elasticbeanstalk describe-environments --environment-names $EB_ENV_NAME --region=eu-west-1 --query "Environments[*].Status" --output text --no-include-deleted`

if [ "$env_status" == "Ready" ]; then
	echo "environment $EB_ENV_NAME is up and ready"
else
	echo "environment $EB_ENV_NAME failed to provision"
	exit 1
fi




