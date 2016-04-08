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
N=0
cd $DEMO_BASE/in

process() {
    FILE="$1"
    if [ "`is_valid "$FILE"`" = "true" ]; then
        echo "Invoicing: file $FILE processed succesfully"
        log_to_aino "$FILE" success
    else
        echo "Invoicing: file $FILE processing failed"
        log_to_aino "$FILE" failure
    fi
    rm "$FILE"
}


while [ 1 ]
do
        if [ "`ls |grep xml`" != "" ]; then
        for FILE in `ls *.xml`
        do
            N=0
            process "$FILE"
        done

    fi


    if [ "$N" -gt 10 ]; then
        echo "No new messages for invoicing in 10 seconds, exiting"
        exit 0
    fi
    sleep 1
    N=`expr $N + 1`

done
