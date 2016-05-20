#!/bin/bash
EB_APP_NAME=$1
EB_ENVIRONMENTS=$2

#HardCoded the Environment Name, We only need it to initialize EB. Not really important to set environemnt since we only uploading saved configs to s3
echo "Fix Env name"
sudo sed -i "s/<ENV>/rates-query-int/" .elasticbeanstalk/config.yml
echo "Fix App name"
sudo sed -i "s/<APP>/$EB_APP_NAME/" .elasticbeanstalk/config.yml
echo "Fix sc"
sudo sed -i "s/sc: git/sc: null/" .elasticbeanstalk/config.yml

ENVS="$(echo $EB_ENVIRONMENTS | sed "s/,/ /g")"

for env in $ENVS
do
  echo "Uploading Saved Config for ENV $env"
  eb config put "$env" || exit 1
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