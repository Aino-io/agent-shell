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

extract_tag() {
    TAG="$1"
    xmllint --recover --format "$2" 2>/dev/null | grep "$TAG" |cut -d'>' -f2|cut -d'<' -f1|tr '\n' ' '
}

start_suite() {
    SUITE_NAME="$1"
    export T0="`date +%s`"
    N_TESTS=0
    FAILURES=0
    TESTCASES=""
}

record_failure() {
    N_TESTS=`expr $N_TESTS + 1`
    FAILURES=`expr $FAILURES + 1`
    NAME=$1
    MESSAGE=$2
    OUTPUT=$3
    TESTCASES="${TESTCASES}
    <testcase name=\"$NAME\" time=\"$SECONDS\">"
    TESTCASES="${TESTCASES}
    <failure message=\"$MESSAGE\" type=\"Assertion error\"><![CDATA["
    TESTCASES="${TESTCASES}
    ${OUTPUT}]]></failure>"
    TESTCASES="${TESTCASES}</testcase>"
}
record_success() {
    N_TESTS=`expr $N_TESTS + 1`
    NAME=$1
    T2="`date +%s`"
    SECONDS="`expr $T2 - $T0`"
    TESTCASES="${TESTCASES}
    <testcase name=\"$NAME\" time=\"$SECONDS\"></testcase>
    "
}
output_suite() {
        T1="`date +%s`"
        SECONDS="`expr $T1 - $T0`"
        echo "<testsuite name=\"$SUITE_NAME\" time=\"$SECONDS\" tests=\"$N_TESTS\" errors=\"0\" skipped=\"0\" failures=\"$FAILURES\">"
        echo "$TESTCASES"
        echo "</testsuite>"

}
gather_ids() {
    extract_tag customerId "$1"
}
log_to_aino() {
    FILENAME="$1"
    STATUS="$2"
    IDS="`gather_ids "$FILENAME"`"
    MESSAGE="Updated customer invoicing address successfully."
    if [ "$STATUS" = "failure" ]; then
        MESSAGE="Customer invoicing address update failed"
    fi

    ${AINO_HOME}/aino.sh --from "CRM" --to "Invoicing" --status "$STATUS" \
		  --message "$MESSAGE" \
          --payload "Customer Invoicing Address" --operation "Customer Details Update" \
           --flowid "$FILENAME" \
           --id "Customer ID" $IDS
}

is_valid() {
    VALID=false
    xmllint "$1" >& /dev/null && VALID=true
    echo $VALID
}

one_in_five() {
    cities=("false" "false" "true" "false" "false")
    city=${cities[$RANDOM % ${#cities[@]} ]}
    echo $city
}
