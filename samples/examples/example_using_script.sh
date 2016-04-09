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

export AINO_HOME="../../scripts"

${AINO_HOME}/aino.sh --from "CRM" --to "Invoicing" --status "success" \
		  --message "Updated customer invoicing address successfully." \
          --payload "Customer Invoicing Address" --operation "Customer Details Update" \
           --flowid "af75d5da-5a5c-4cf2-bd6e-3be813ea2145" \
           --id "Customer ID" "123" \
           --id "Order ID" "234" \
           --id "Random ID" "abc" "123" "xyzzy" \
           --config ../demo/aino-config.sh \
           --verbose
