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

export AINO_HOME=$PWD/../scripts
export DEMO_BASE=$PWD
export AINO_PAYLOAD_OUT="$DEMO_BASE/aino.out"
export AINO_HTTP_OUT="$DEMO_BASE/curl.out"
export SUREFIRE=$PWD/TEST-io.aino.shell.ShellAgentTest.xml

echo > $AINO_PAYLOAD_OUT
export EXIT_CODE=0

cleanup() {
    rm -f aino.out ids.out failure.count success.count curl.out failures.txt
}
# Do not read AINO_API_KEY so we can use one from CI environment
#. $DEMO_BASE/demo/aino-config.sh
. $DEMO_BASE/lib/test-functions.sh

cleanup

start_suite "io.aino.shell.ShellAgentTest"

. tests/test_twosystem.sh
. tests/test_aino_metadata.sh

for IMPL in Wget Curl
do
    export IMPLEMENTATION=`echo $IMPL|tr A-Z a-z`
    OK_API_KEY=$AINO_API_KEY

    . tests/test_aino_log_success.sh $IMPL
    . tests/test_aino_log_failure.sh $IMPL

    export AINO_API_KEY=$OK_API_KEY
done


output_suite > $SUREFIRE

cleanup

output_summary

exit $EXIT_CODE
