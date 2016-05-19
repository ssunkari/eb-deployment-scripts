#!/bin/bash
EB_APP_NAME=$1
eb init "$EB_APP_NAME" -r eu-west-1
eb config put rates-query-int
eb config put rates-query-qa
eb config put rates-query-qa-perf
eb config put rates-query-uat