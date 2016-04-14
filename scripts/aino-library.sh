#! /bin/sh
# This file contains the functions used by aino.io bourne shell implementation
# You should not need to customize this file

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

# Implementation can be one of autodetect / curl / wget. Value autodetect will detect presence of either curl or wget. It is the default
# The setting can also be overwritten int aino-config.sh
if [ "$IMPLEMENTATION" = "" ]; then
    IMPLEMENTATION="autodetect"
fi
# This is the URL to which data will be posted. This variable can also be overwritten in the aino-config if needed
if [ "$AINO_URL" = "" ]; then
    AINO_URL="https://data.aino.io/rest/v2.0/transaction"
fi
IDS=""
METADATA=""

if [ -e "${AINO_HOME}/base-functions.sh" ]; then
    . "${AINO_HOME}/base-functions.sh"
fi


timestamp() {
    date +"%s"
}

verbose_aino() {
    export VERBOSE_AINO=false
    if [ "$1" = "on" ]; then
        export VERBOSE_AINO=true
    fi
    if [ "$1" = "true" ]; then
        export VERBOSE_AINO=true
    fi
}
detect_implementation() {
    if [ "`which curl`" != "" ]; then
        echo curl
    elif  [ "`which wget`" != "" ]; then
        echo wget
    fi

}


# ID handling related functions
reset_aino_ids() {
    IDS=""
}

get_aino_ids() {
    echo "$IDS"
}


append_id() {
    if [ "$IDS" = "" ]; then
        IDS='"ids": [ {'
    else
        IDS="${IDS},{"
    fi
    IDS="${IDS} \"idType\": \"$1\", \"values\": [ $2 ] }"
}

add_aino_id() {
        ID_TYPE="$1"
        shift
        append_id "$ID_TYPE" "`get_until_option $*`"
}

get_until_option() {
    CONT="true"
    GEN_VALUE=""
    while [ "$CONT" = "true" ]; do
        if [ "$GEN_VALUE" != "" ]; then
            GEN_VALUE="${GEN_VALUE}, "
        fi
        GEN_VALUE="${GEN_VALUE}\"$1\""
        if [ "`echo \"$2\"|cut -c1`" = "-" ]; then
            CONT=false
        else
            shift
        fi
        if [ $# -eq 0 ]; then
            CONT="false"
        fi
    done
    echo "$GEN_VALUE"
}

# Metadata handling functions


reset_aino_metadata() {
    METADATA=""
}

get_aino_metadata() {
    if [ "$METADATA" != "" ]; then
        echo "\"metadata\": [ $METADATA ],"

    fi
}


add_aino_metadata() {
    if [ "$METADATA" != "" ]; then
        METADATA="${METADATA},"
    fi
    METADATA="$METADATA{  \"name\": \"$1\", \"value\": \"$2\" }"
}


init_flow_id() {
	export EXPORTED_AINO_FLOW_ID="`generate_flow_id`"
}

# Return or generate a flow ID
generate_flow_id() {
	if [ "${EXPORTED_AINO_FLOW_ID}" != "" ]; then
		echo "${EXPORTED_AINO_FLOW_ID}"
	else
		echo "$0-`timestamp`-$$"
	fi
}

# Network IO related functions





do_send() {
    if [ "${IMPLEMENTATION}" = "autodetect" ]; then
        IMPLEMENTATION=`detect_implementation`
    fi

	if [ "${IMPLEMENTATION}" = "curl" ]; then
	    ${AINO_HOME}/send_curl.sh "$1" "$2" "$AINO_URL" "$AINO_API_KEY" &
	elif [ "${IMPLEMENTATION}" = "wget" ]; then
	    ${AINO_HOME}/send_wget.sh "$1" "$2" "$AINO_URL" "$AINO_API_KEY" &
    else
	    echo "No implementation for communicating with aino.io found. Please install curl or wget."
	    exit 1
	fi
}



aino_log() {
    FROM=$1
    TO=$2
    STATUS=$3
    MESSAGE=$4
    TIMESTAMP=`timestamp`
    TIMESTAMP="`expr $TIMESTAMP \* 1000`"
    OPERATION=$5
    PAYLOAD=$6
	FLOW_ID=$7
	IDS="$8"

	if [ "$AINO_API_KEY" = "" ]; then
	    if [ -e "${AINO_HOME}/aino-config.sh" ]; then
	        . "${AINO_HOME}/aino-config.sh"
	    fi
	fi
    if [ "$IDS" != "" ]; then
        IDS="${IDS} ],"
    fi

    if [ "${STATUS}" != "success" ]; then
        if [ "${STATUS}" != "failure" ]; then
            if [ "${STATUS}" != "unknown" ]; then
                echo "Invalid status '${STATUS}'. Setting it to 'unknown'. Valid values are 'success', 'failure' and 'unknown'."
                STATUS="unknown"
            fi
        fi
    fi

    JSON_MESSAGE="`create_json`"
    if [ "${VERBOSE_AINO}" = "true" ]; then
        echo "JSON payload is:"
        echo "$JSON_MESSAGE"
        echo

        echo "Aino URL is $AINO_URL"
    fi
    if [ "$AINO_PAYLOAD_OUT" != "" ]; then
        echo "$JSON_MESSAGE" >> "${AINO_PAYLOAD_OUT}"
    fi

    do_send "${AINO_URL}" "${JSON_MESSAGE}"
    IDS=""
}


create_json() {
    METADATA_OUT="`get_aino_metadata`"
    cat << :EOF:

{
  "transactions": [
    {
      "from": "${FROM}",
      "to": "${TO}",
      "status": "${STATUS}",
      "timestamp": "${TIMESTAMP}",
      "message": "${MESSAGE}",
      "operation": "${OPERATION}",
      "payloadType": "${PAYLOAD}",
       ${IDS}
       ${METADATA_OUT}
      "flowId": "${FLOW_ID}"
    }
  ]
}

:EOF:

}
