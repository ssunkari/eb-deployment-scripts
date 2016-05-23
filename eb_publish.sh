#!/bin/bash

# usage:  -c ./deploy.sh ${EB_APP_NAME} ${GO_PIPELINE_LABEL} ${S3_BUCKET} ${AWS_ACCOUNT_ID} ${NODE_ENV} ${PORT} ${BRANCH} ${HTTP_PROXY} ${HTTPS_PROXY} ${NO_PROXY}

EB_APP_NAME=$1
SHA1=$2
EB_BUCKET=$3
AWS_ACCOUNT_ID=$4
NODE_ENV=$5
PORT=$6
BRANCH=$7
HTTP_PROXY=$8
HTTPS_PROXY=$9
NO_PROXY=$10

VERSION=$EB_APP_NAME-$SHA1
ZIP=$VERSION.zip

existing_app=`aws elasticbeanstalk describe-application-versions --application-name "$EB_APP_NAME" --version-label "$VERSION" --query "ApplicationVersions[*].VersionLabel" --output text`
if [ "$existing_app" != "$VERSION" ]; then
	echo "Replacing HTTP_PROXY=$HTTP_PROXY, NO_PROXY=$NO_PROXY"
	sudo sed -i "s/<AWS_ACCOUNT_ID>/$AWS_ACCOUNT_ID/" Dockerrun.aws.json
	sudo sed -i "s/<NAME>/$EB_APP_NAME/" Dockerrun.aws.json
	sudo sed -i "s/<PORT>/$PORT/" Dockerrun.aws.json
	sudo sed -i "s/<TAG>/$SHA1/" Dockerrun.aws.json
	sudo sed -i "s/<NODE_ENV>/$NODE_ENV/" .ebextensions/env-vars.config
	sudo sed -i "s/<HTTP_PROXY>/$HTTP_PROXY/" .ebextensions/env-vars.config
	sudo sed -i "s/<HTTPS_PROXY>/$HTTPS_PROXY/" .ebextensions/env-vars.config
	sudo sed -i "s/<NO_PROXY>/$NO_PROXY/" .ebextensions/env-vars.config

	sudo zip -r $ZIP Dockerrun.aws.json .ebextensions

	aws s3 cp $ZIP s3://$EB_BUCKET/$ZIP

	# Create a new application version with the zipped up Dockerrun file
	aws elasticbeanstalk create-application-version --application-name $EB_APP_NAME \
	    --version-label $VERSION --description "Automated build ($BRANCH)" --source-bundle S3Bucket=$EB_BUCKET,S3Key=$ZIP
fi
