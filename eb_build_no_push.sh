#!/bin/bash

# usage:  -c ./eb_build.sh ${GO_PIPELINE_LABEL} ${AWS_ACCOUNT_ID} ${EB_APP_NAME} ${PROXY_URL} ${NO_PROXY} ${PORT}

SHA1=$1
AWS_ACCOUNT_ID=$2
EB_APP_NAME=$3
PROXY_URL=$4
NO_PROXY=$5
PORT=$6

sudo sed -i "s/EXPOSE [0-9]\+$/EXPOSE $PORT/" Dockerfile

sudo docker build -t $EB_APP_NAME:$SHA1 --build-arg http_proxy=$PROXY_URL --build-arg https_proxy=$PROXY_URL --build-arg no_proxy=$NO_PROXY .
sudo docker run -i -a STDOUT --rm -e NODE_ENV=ci -e GO_PIPELINE_LABEL=$SHA1 $EB_APP_NAME:$SHA1 grunt
OUT=$?
if [ $OUT != 0 ]; then
	exit $OUT
fi