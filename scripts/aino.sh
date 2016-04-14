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

# AINO_HOME environment variable tells us where the aino configuration is
# If no AINO_HOME environment variable is defined, then assume it is at the same directory as this script
if [ "$AINO_HOME" = "" ]; then
    AINO_HOME=.
fi

if [ -e "${AINO_HOME}/aino-library.sh" ]; then
    . "${AINO_HOME}/aino-library.sh"
fi



print_help() {
    echo "Usage: aino.sh --from \"<origin system>\" --to \"<target system>\" --status \"<success|failure>\"  --message \"<message explaining transaction>\" \\"
    echo "               --operation \"<business process name>\" --payload \"<type of payload>\""

    echo ""
    echo "Optional flags:"
	echo "  --flowid    \"[flowid]\"            Send the specified value as flow ID"
    echo "  --verbose                           Do verbose output"
    echo "  --config    <configuration file>    Load aino.io configuration (e.g. API key) from this file"

    echo ""
    echo "Identifier handling:"
    echo "  Single field:"
    echo "    --id \"ID name\" \"ID value\""
    echo "  Or for multivalued IDs (arrays of values):"
    echo "    --id \"ID name\" \"ID value 1\" \"ID value 2\" \"ID value 3\""
    echo ""
    echo "Metadata (optional):"
    echo "  You can send any metadata related to the call by using the --metadata option:"
    echo "  --metadata \"Metadata field\" \"Value of field\""
    echo "  --send-hostname Sends the hostname where the script is running as metadata"
    echo "  --send-artifact Sends information about the script that is calling aino as metadata"
    exit 1


}

if [ "$#" -lt 10 ]; then
    print_help
    exit 1
fi
while [ $# -gt 0 ]
do

  case "$1" in
    --help)
        print_help
        exit 0
    ;;
    --config)
        . "$2"
    ;;
    --to)
      TO="$2"
      ;;
    --from)
      FROM="$2"
      ;;
    --status)
      STATUS="$2"
      ;;
    --message)
      MESSAGE="$2"
      ;;
    --operation)
      OPERATION="$2"
      ;;
    --payload)
      PAYLOAD="$2"
      ;;
    --flowid)
      FLOWID="$2"
      ;;
    --id)
        if [ "$#" -lt 3 ]; then
            echo "Invalid parameters passed to aino.sh: $*"
            exit 1
        fi
        shift # Shift the --id off stack
        ID_TYPE="$1"
        shift # Shift the type off the stack
        add_aino_id "$ID_TYPE" $*
      ;;
   --metadata)
        if [ "$#" -lt 3 ]; then
            echo "Invalid parameters passed to aino.sh: $*"
            exit 1
        fi
        shift # Shift the --id off stack
        METADATA_FIELD="$1"
        shift # Shift the type off the stack
        add_aino_metadata "$METADATA_FIELD" "$1"
      ;;
    --send-artifact)
        add_aino_metadata "artifactType" "shellScript"
        add_aino_metadata "artifactName" "`ps -o args= $PPID`"
    ;;
    --send-hostname)
        add_aino_metadata "serverName" "`hostname`"
    ;;
    --verbose)
        export VERBOSE_AINO=true
      ;;
    --help)
        help
        exit 0
    ;;
  esac
  shift
done

if [ "${FLOWID}" = "" ]; then
	FLOWID=`generate_flow_id`
fi

aino_log "${FROM}" "${TO}" "${STATUS}" "${MESSAGE}" "${OPERATION}" "${PAYLOAD}" "${FLOWID}" "`get_aino_ids`"
