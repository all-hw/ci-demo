#!/bin/bash

# CI Server REST API URL
REST=https://cloud.all-hw.com/ci
# Verbose output on REST API requests/responses: either "-v" or empty
VERBOSE=

# INPUT_API_KEY=ba1e491b-331b-4e35-b799-f714b8505843
INPUT_TIMEOUT=10
# INPUT_FILE=test_data/uart_input.txt
# INPUT_BINARY=bin/HelloW.axf


echo Executing $INPUT_BINARY on $REST with timeout ${INPUT_TIMEOUT}s
TOC=`curl -X POST -F firmware=@$INPUT_BINARY -F input=@$INPUT_FILE $VERBOSE "$REST/usertask?timeout=$INPUT_TIMEOUT&key=$INPUT_API_KEY" 2>/dev/null`

echo Waiting for result... $TOC
OUT=
while [ "x$(echo "$OUT" | grep "\"status\":\"finished\"")" == "x" ]
do
sleep 1
OUT=`curl -X GET $VERBOSE "$REST/usertask?id=$TOC" 2>/dev/null`
done

echo "Result code: `echo $OUT | jq -c -r .code`"
echo "UART output: =================VVVVVVVVVVVVV================================="
echo $OUT | jq -c -r .output
echo "==============================^^^^^^^^^^^^^================================="
exit 0