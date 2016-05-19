#!/bin/bash
EB_APP_NAME=$1
eb init "$EB_APP_NAME" -r eu-west-1
eb config put rates-quer-int
eb config put rates-quer-qa
eb config put rates-quer-qa-perf
eb config put rates-quer-uat