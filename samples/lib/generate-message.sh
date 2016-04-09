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

MESSAGE="`cat $DEMO_BASE/lib/address.xml`"

generate_street() {
    streets=("Itämerenkatu 1" "Rautpohjankatu 15" "Gatuköksgatan 99")
    street=${streets[$RANDOM % ${#streets[@]} ]}
    echo $street
}

generate_city() {
    cities=("Helsinki" "Jyväskylä" "Borgå")
    city=${cities[$RANDOM % ${#cities[@]} ]}
    echo $city
}
generate_postal_zone() {
    echo ${RANDOM}${RANDOM}${RANDOM} | cut -c1-5
}

generate_country() {
echo "FI"
}

generate_message() {
    MESSAGE="`echo "$1"|sed s/CUSTOMER_ID${2}/$RANDOM/g`"
    STREET="`generate_street`"
    CITY="`generate_city`"
    PZ="`generate_postal_zone`"
    COUNTRY="`generate_country`"
    MESSAGE="`echo "$MESSAGE"|sed s/STREET${2}/"$STREET"/g`"
    MESSAGE="`echo "$MESSAGE"|sed s/CITY${2}/"$CITY"/g`"
    MESSAGE="`echo "$MESSAGE"|sed s/POSTAL_CODE${2}/"$PZ"/g`"
    MESSAGE="`echo "$MESSAGE"|sed s/COUNTRY${2}/"$COUNTRY"/g`"


    echo "$MESSAGE"
}

for i in 1 2 3
do
    MESSAGE="`generate_message "$MESSAGE" $i`"
done
echo "$MESSAGE"
