#!/bin/sh
	if [ "`which curl`" = "" ]; then
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
    	OUTPUT="`curl -w \"\n%{http_code}\n\" -v -X POST -H\"Authorization: apikey ${AINO_API_KEY}\" -H'Content-type: application/json' ${AINO_URL} --data \"$2\" 2>&1`"
    	echo "$OUTPUT"
        echo "$OUTPUT" > $OUT
        STATUSCODE="`echo \"$OUTPUT\"|tail -n1`"
        ERROR="`echo \"$OUTPUT\"|tail -n2|head -n1`"
	else
    	OUTPUT="`curl --silent  -w \"\n%{http_code}\n\"  -X POST -H\"Authorization: apikey \${AINO_API_KEY}\" -H"Content-type: application/json" ${AINO_URL} --data \"$2\" 2>&1`"
        echo "$OUTPUT" > $OUT
        STATUSCODE="`echo \"$OUTPUT\"|tail -n1`"
        ERROR="`echo \"$OUTPUT\"|tail -n2|head -n1`"
	fi
	if [ "$STATUSCODE" != "200" -a "$STATUSCODE" != "202" ]; then
        if [ "`which tput`" != "" ]; then
            tput setaf 1

        fi
	    echo "Error: Failed to send message to aino: $STATUSCODE $ERROR"
	    if [ "`which tput`" != "" ]; then
            tput sgr0
        fi
	fi
	export AINO_STATUS_CODE=$STATUS_CODE

