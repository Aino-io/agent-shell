#! /bin/sh

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
. $DEMO_BASE/lib/test-functions.sh

start_test


export SILENT_MODE=1
./systems/invoicing.sh &
./systems/crm.sh 10 unittest



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




if [ -e failures.txt ]; then
    record_failure testAinoLoggingFromShell "Wrong number of failures or wrong IDs" "`cat failures.txt`"
    EXIT_CODE=1
else
    record_success testAinoLoggingFromShell
fi
