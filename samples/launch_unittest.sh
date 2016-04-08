#! /bin/bash

#   Copyright 2016 Aino.io
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

export AINO_HOME=$PWD/../scripts
export DEMO_BASE=$PWD
export AINO_PAYLOAD_OUT="$DEMO_BASE/aino.out"
export AINO_HTTP_OUT="$DEMO_BASE/curl.out"

echo > $AINO_PAYLOAD_OUT

# Do not read AINO_API_KEY so we can use one from CI environment
#. $DEMO_BASE/demo/aino-config.sh
. $DEMO_BASE/lib/test-functions.sh

#java -jar lib/loggerservice*.jar 9000 ci no_database &
#LOGGER_PID=$!
#echo $LOGGER_PID > logger.pid
#echo "Launched logger service to serve as unittest Aino backend with pid $LOGGER_PID"
#sleep 15

rm -f aino.out ids.out failure.count success.count failures.txt
start_suite "fi.mystes.aino.io.shell.ShellPluginTest"
T0="`date +%s`"

./systems/invoicing.sh &
./systems/crm.sh 15 unittest

T1="`date +%s`"
SECONDS="`expr $T1 - $T0`"

for ID in `cat ids.out`
do
    if [ "`grep "Customer ID.*$ID" aino.out`" = "" ]; then
        echo "ID $ID not found" >> failures.txt
    fi
done

# Calculate the number of succesful invocations
SUCCESS_COUNT="`grep "status.*success" aino.out|wc -l|sed "s/ //g"`"
EXPECTED_COUNT="`cat success.count`"
# Compare to expected
if [ "$SUCCESS_COUNT" != "$EXPECTED_COUNT" ]; then
    echo "Wrong number of successful invocations. Was $SUCCESS_COUNT. Expected $EXPECTED_COUNT" >> failures.txt
fi

# Calculate number of failures
FAILURE_COUNT="`grep "status.*failure" aino.out|wc -l|sed "s/ //g"`"
EXPECTED_COUNT="`cat failure.count`"
# Compare to expected
if [ "$FAILURE_COUNT" != "$EXPECTED_COUNT" ]; then
    echo "Wrong number of failed invocations. Was $FAILURE_COUNT. Expected $EXPECTED_COUNT" >> failures.txt
fi


SUREFIRE=$PWD/TEST-fi.mystes.aino.io.shell.ShellPluginTest.xml

EXIT_CODE=0

if [ -e failures.txt ]; then
    record_failure testAinoLoggingFromShell "Wrong number of failures or wrong IDs" "`cat failures.txt`"
    EXIT_CODE=1
else
    record_success testAinoLoggingFromShell
fi

# Do a succesful invocation
${AINO_HOME}/aino.sh --from "CRM" --to "Invoicing" --status "success" \
		  --message "Updated customer invoicing address successfully." \
          --payload "Customer Invoicing Address" --operation "Customer Details Update" \
           --flowid "af75d5da-5a5c-4cf2-bd6e-3be813ea2145" \
           --id "Customer ID" "123" \
           --id "Order ID" "234" \
           --id "Random ID" "abc" "123" "xyzzy"
sleep 1
CURL_OUT="`cat curl.out`"
# Check that we got correct response from Aino for our invocations
if [ "`grep batchId curl.out`" != "" ]; then
    record_success testAinoResponse
else
    record_failure testAinoResponse "Wrong response from aino.io, expected to contain batchId" "$CURL_OUT"
    EXIT_CODE=1
fi

# Then do an aino log call with bad API key to check that we correctly detect errors
export AINO_API_KEY="bad api key"
${AINO_HOME}/aino.sh --from "CRM" --to "Invoicing" --status "success" \
		  --message "Updated customer invoicing address successfully." \
          --payload "Customer Invoicing Address" --operation "Customer Details Update" \
           --flowid "af75d5da-5a5c-4cf2-bd6e-3be813ea2145" \
           --id "Customer ID" "123" \
           --id "Order ID" "234" \
           --id "Random ID" "abc" "123" "xyzzy"
sleep 1

CURL_OUT="`cat curl.out`"
# Verify that the output contains Invalid API key
if [ "`echo $CURL_OUT|grep \"Invalid API key\"`" = "" ]; then
    record_failure testAinoResponseForInvalidRequest "Wrong response from aino.io for invalid request" "$CURL_OUT"
    EXIT_CODE=1
else
    record_success testAinoResponseForInvalidRequest
fi

output_suite > $SUREFIRE

# Clean up files used during testing
rm -f ids.out failure.count success.count aino.out curl.out
exit $EXIT_CODE
