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

. ../demo/aino-config.sh

# Switch to verbose mode
verbose_aino on

# Initialize a flow ID that is exported to the environment
# and will be available to other scripts invoked within this shell script
#
# If init_flow_id is not called, then generate_flow_id will each time return a new flow ID
init_flow_id

add_aino_id "Customer ID" "123"
add_aino_id "Order ID" "234"
add_aino_id "Random ID" "abc" "123" "xyzzy"

aino_log "CRM" "Invoicing" "success"  "Updated customer invoicing address successfully." \
         "Customer Details Update"  "Customer Invoicing Address"  \
         "`generate_flow_id`" "`get_aino_ids`"
