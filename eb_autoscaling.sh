#!/bin/bash

# Suspends an auto scaling group which belongs to EB_ENV_NAMES (comma seperated list of environments)

#usage ./eb_autoscaling.sh suspend/resume ${EB_ENV_NAMES}

ACTION=$1
EB_ENV_NAMES=$2
ENVS="$(echo $EB_ENV_NAMES | sed "s/,/ /g")"
PROBLEM="0"

for env in $ENVS
do
  echo "Processing $ACTION for $env"
  autoscaling_group=`aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?Tags[?Key=='Name' && Value=='"$env"']].AutoScalingGroupName" --output text` 

  if [ "$autoscaling_group" == "" ]; then
    echo "No autoscaling group found for $env"
    $PROBLEM="1"
    continue
  fi

  if [ "$ACTION" == "suspend" ]; then
    aws autoscaling suspend-processes --auto-scaling-group-name "$autoscaling_group"
    echo "Suspended group $autoscaling_group ($env)"
    continue
  fi

  if [ "$ACTION" == "resume" ]; then
    aws autoscaling resume-processes --auto-scaling-group-name "$autoscaling_group"
    echo "Resumed group $autoscaling_group ($env)"
    continue
  fi
done

if [ "$PROBLEM" == "1"]; then
  exit 1
fi