#!/bin/bash

INPUT_API_KEY=ba1e491b-331b-4e35-b799-f714b8505843

# CI Server REST API URL
REST=https://cloud.all-hw.com/ci
# User task timeout
TIMEOUT=10
# Verbose output on REST API requests/responses: either "-v" or empty
VERBOSE=
# Self-signed CA certificate used by the CI Server

P_2=$2
P_3=$3

task_status() {
curl -X GET $VERBOSE "$REST/usertask?id=$P_2"
echo
}

create_task() {
curl -X POST -F firmware=@$P_2 -F input=@$P_3 $VERBOSE "$REST/usertask?timeout=$TIMEOUT&key=$INPUT_API_KEY"
}

case "$1" in
status)
task_status
;;
task)
create_task
;;
esac

exit 0