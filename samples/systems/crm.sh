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

. $DEMO_BASE/lib/test-functions.sh

# By default generate 5 messages and stop
N=5
if [ ! -e $DEMO_BASE/in ]; then
    mkdir $DEMO_BASE/in
fi

if [ -e logger.pid ]; then
    kill `cat logger.pid` >& /dev/null
    rm -f logger.pid
fi

# If first paramter is given, then use that as the amount of messages
if [ "$1" != "" ]; then
    N=$1
fi
if [ "$2" == "unittest" ]; then
    rm -f success.count failure.count ids.out
fi
I=0
output "CRM exporting $N updates"

N_SUCCESS=0
N_FAILURE=0

while [ "$I" -lt "$N" ]
do
    # Generate a sample message from CRM
    FILENAME="addrdata-${RANDOM}-`date +%s`.xml"
    $DEMO_BASE/lib/generate-message.sh > $DEMO_BASE/in/${FILENAME}

    # If we're run in unittest mode, then gather the message IDs for verification
    if [ "$2" == "unittest" ]; then
        gather_ids $DEMO_BASE/in/${FILENAME} >> ids.out
    fi

    # Introduce an error to the file with frequency of 1/5 (20%). Keep count of successes and failures
    if [ "`one_in_five`" = "true" ]; then
        output "CRM: Exporting BROKEN customer details update to $FILENAME"
        echo "<THIS IS BROKEN XML>" >> $DEMO_BASE/in/${FILENAME}
        N_FAILURE="`expr $N_FAILURE + 1`"
    else
        output "CRM: Exporting customer details update to $FILENAME"
            N_SUCCESS="`expr $N_SUCCESS + 1`"
    fi
    sleep 1
    I=`expr $I + 1`
done

sleep 10

if [ "$2" == "unittest" ]; then
    echo $N_SUCCESS > success.count
    echo $N_FAILURE > failure.count
fi

# Log failure for all files that were not processed in 30 seconds
cd $DEMO_BASE/in

if [ "`ls |grep xml`" != "" ]; then
    for FILE in `ls *.xml`
    do
        log_to_aino "$FILE" failure
    done
fi

