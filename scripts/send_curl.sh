#!/bin/sh
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

if [ -e "${AINO_HOME}/base-functions.sh" ]; then
    . "${AINO_HOME}/base-functions.sh"
fi
	if [ "`which curl 2> /dev/null`" = "" ]; then
		echo "Curl not found."
		exit 1
	fi
	OUT=/dev/null
	if [ "$AINO_HTTP_OUT" != "" ]; then
	    OUT=$AINO_HTTP_OUT
	fi
	AINO_URL="$3"
	AINO_API_KEY="$4"
	if [ "${VERBOSE_AINO}" = "true" ]; then
        if [ "$AINO_DISABLE_GZIP" = "true" -o "`check_gzip`" = "false" ]; then
            OUTPUT="`curl -w \"\n%{http_code}\n\" -v -X POST -H\"Authorization: apikey ${AINO_API_KEY}\" -H'Content-type: application/json' ${AINO_URL} --data \"$2\" 2>&1`"
            echo "Command: curl -w \"\n%{http_code}\n\" -v -X POST -H\"Authorization: apikey ${AINO_API_KEY}\" -H'Content-type: application/json' ${AINO_URL} --data \"payload\" 2>&1"
        else
            OUTPUT="`echo \"$2\" | gzip -cf - | curl -w \"\n%{http_code}\n\" -v -X POST -H\"Content-Encoding: gzip\" -H\"Authorization: apikey ${AINO_API_KEY}\" -H'Content-type: application/json' ${AINO_URL} --data-binary @- 2>&1`"
            echo "Command: echo \"payload\" | gzip -cf - | curl -w \"\n%{http_code}\n\" -v -X POST -H\"Content-Encoding: gzip\" -H\"Authorization: apikey ${AINO_API_KEY}\" -H'Content-type: application/json' ${AINO_URL} --data-binary @- 2>&1"
        fi
    	echo "$OUTPUT"
        echo "$OUTPUT" > $OUT
        STATUSCODE="`echo \"$OUTPUT\"|tail -n1`"
        ERROR="`echo \"$OUTPUT\"|tail -n2|head -n1`"
	else
        if [ "$AINO_DISABLE_GZIP" = "true" ]; then
            OUTPUT="`curl --silent  -w \"\n%{http_code}\n\"  -X POST -H\"Authorization: apikey \${AINO_API_KEY}\" -H"Content-type: application/json" ${AINO_URL} --data \"$2\" 2>&1`"
        else
            OUTPUT="`echo \"$2\" | gzip -cf - | curl --silent  -w \"\n%{http_code}\n\"  -X POST -H\"Content-Encoding: gzip\" -H\"Authorization: apikey ${AINO_API_KEY}\" -H"Content-type: application/json" ${AINO_URL} --data-binary @- 2>&1`"
        fi
        echo "$OUTPUT" > $OUT
        STATUSCODE="`echo \"$OUTPUT\"|tail -n1`"
        ERROR="`echo \"$OUTPUT\"|tail -n2|head -n1`"
	fi
	if [ "$STATUSCODE" != "200" -a "$STATUSCODE" != "202" ]; then
        red
	    echo "Error: Failed to send message to aino: $STATUSCODE $ERROR"
	    normal
	fi
	export AINO_STATUS_CODE=$STATUSCODE

