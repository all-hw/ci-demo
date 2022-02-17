#!/bin/bash

# CI Server REST API URL
REST=https://cloud.all-hw.com/ci
API_KEY=177aa96d-424f-40b2-817c-3034d38c87b6

# User task timeout
TIMEOUT=60
# Verbose output on REST API requests/responses: either "-v" or empty
VERBOSE=

P_2=$2
P_3=$3
P_4=$4

if [[ "x$LOG" == "x" ]]; then
    LOG=0
fi

task_status() {
    LOG=$(mktemp /tmp/run.XXXX.log)
    curl -X GET $VERBOSE "$REST/usertask?id=$P_2" 2>/dev/null > $LOG
    
    STATUS=`cat $LOG | jq -c -r .status`

    echo Status: $STATUS
    if [[ "x$STATUS" == "xfinished" ]]; then
        echo Exit code: `cat $LOG | jq -c -r .code`
        echo UART output: 
        cat $LOG | jq -c -r .output
    fi
    rm $LOG
}

create_task() {
    curl -s -X POST -F firmware=@$P_2 -F input=@$P_3 -F config=@$P_4 $VERBOSE "$REST/usertask?version=V4&log=$LOG&timeout=$TIMEOUT&key=$API_KEY"
    echo
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
