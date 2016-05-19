#!/bin/bash

# Suspends an auto scaling group which belongs to EB_APP_NAME

#usage ./eb_autoscaling.sh suspend/resume ${EB_APP_NAME}

ACTION=$1
EB_APP_NAME=$2

autoscaling_group=`aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?Tags[?Key=='Name' && Value=='"$EB_APP_NAME"']].AutoScalingGroupName" --output text`

if [ "$autoscaling_group" == "" ]; then
	echo "No autoscaling group found for $EB_APP_NAME"
	exit 1
fi

if [ "$ACTION" == "suspend" ]; then
	aws autoscaling suspend-processes --auto-scaling-group-name "$autoscaling_group"
	echo "Suspended group $autoscaling_group"
	exit 0
fi

if [ "$ACTION" == "resume" ]; then
	aws autoscaling resume-processes --auto-scaling-group-name "$autoscaling_group"
	echo "Resumed group $autoscaling_group"
	exit 0
fi
