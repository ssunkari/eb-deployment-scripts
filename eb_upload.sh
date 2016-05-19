#!/bin/bash
EB_APP_NAME=$1
EB_ENVIRONMENTS=$2
eb init "$EB_APP_NAME" -r eu-west-1 --quiet
ENVS="$(echo $EB_ENVIRONMENTS | sed "s/,/ /g")"

for env in $ENVS
do
  echo "Uploading Saved Config for ENV $env"
  eb config put "$env"
done

getSavedConfigs=`eb config list`
echo "list of configs fetched from S3 are \n $getSavedConfigs"

for env in $ENVS
do
	configExists=`eb config list | grep ^"$env"$`
	if [ -z "$configExists" ]; then
		echo "Upload Failed, $env saved config is missing in S3"
		exit 1
	fi
done

echo 'Upload finished successfully'