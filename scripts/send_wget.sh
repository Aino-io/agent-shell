#!/bin/sh
	if [ "`which wget`" = "" ]; then
		echo "Wget not found."
		exit 1
	fi
	OUT=/dev/null
	AINO_URL="$3"
	AINO_API_KEY="$4"

	if [ "$AINO_HTTP_OUT" != "" ]; then
	    OUT=$AINO_HTTP_OUT
	fi

    OUTPUT="`wget -nv --server-response --header=\"Authorization: apikey ${AINO_API_KEY}\" --header=\"Content-type: application/json\" ${AINO_URL} --post-data \"$2\" -o $OUT -O $OUT`"
	if [ "${VERBOSE_AINO}" = "true" ]; then
    	echo "$OUTPUT"
    fi
    echo "$OUTPUT" > $OUT
    STATUSCODE="`echo \"$OUTPUT\"|head -n1|cut -d' ' -f4`"
    ERROR="`echo \"$OUTPUT\"|tail -n1`"

	if [ "$STATUSCODE" != "200" -a "$STATUSCODE" != "202" ]; then
        if [ "`which tput`" != "" ]; then
            tput setaf 1

        fi
	    echo "Error: Failed to send message to aino: $STATUSCODE $ERROR"
	    if [ "`which tput`" != "" ]; then
            tput sgr0
        fi
    fi

