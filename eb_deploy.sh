#!/bin/bash

# usage: ./check_eb_deploy.sh EB_APP_NAME EB_ENV_NAME GITSHA

EB_APP_NAME=$1
EB_ENV_NAME=$2
SHA1=$3
VERSION=$EB_APP_NAME-$SHA1

#Its mandatory to init the eb, since the eb commands can only be run after initialization.
eb init $EB_APP_NAME --region eu-west-1
eb deploy $EB_ENV_NAME --version $VERSION

deploystart=$(date +%s)
timeout=3000 # Seconds to wait before error. If it's taking awhile - your boxes probably are too small.
threshhold=$((deploystart + timeout))
while true; do
    # Check for timeout
    timenow=$(date +%s)
    if [[ "$timenow" > "$threshhold" ]]; then
        echo "Timeout - $timeout seconds elapsed"
        exit 1
    fi

    # See what's deployed
    current_version=`aws elasticbeanstalk describe-environments --application-name "$EB_APP_NAME" --environment-name "$EB_ENV_NAME" --query "Environments[*].VersionLabel" --no-include-deleted --output text`

    status=`aws elasticbeanstalk describe-environments --application-name "$EB_APP_NAME" --environment-name "$EB_ENV_NAME" --query "Environments[*].Status" --no-include-deleted --output text`

    if [ "$current_version" != "$VERSION" ]; then
        echo "Tag not updated (currently $current_version). Waiting."
        sleep 10
        continue
    fi
    if [ "$status" != "Ready" ]; then
        echo "System not Ready -it's $status. Waiting."
        sleep 10
        continue
    fi
    break
done