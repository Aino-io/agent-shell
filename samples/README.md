# Structure

The project structure is as follows:
* `scripts/` contains the actual plugin implementation
    *   `aino.sh` A script that can be invoked to log a transaction into aino.io
    *   `aino-library.sh` Functions that implement the logic for connecting into aino.io
    *   `aino-config.sh` Configuration for the logging, including API key.
* `samples/` contains unit tests and examples for getting familiar with the project
    * `demo/` contains an aino configuration file for the unit tests and examples
    * `examples` contains scripts showing various ways to log transactions into aino
        * `example_using_function.sh` Example of how to use the function type invocation with the various aino parameters passed in specific order
        * `example_using_script.sh` Example of how to use the script type invocation with the various aino parameters passed as named parameters to the script
    * `lib/` contains various scripts and files used in the demos and unit tests
    * `launch_unittest.sh` Launches a unittest that will generate a results file under target/surefire-reports
    * `launch_demo.sh` Launches a demo that will generate invocations into aino.io using the API key specified in demo/aino-config.sh
    * `systems/` contains scripts that implement CRM and invoicing systems logging their transactions into aino in the demo / unittests


# Underlying command line tools
The aino.io shell plugin uses either `curl` or `wget` to communicate with aino.io. By default
the presence of curl or wget is autodetected (with curl being the preferred choice) and used, so
having either available is enough to use aino.io shell plugin.

If you wish to avoid autodetection and enforce use of either `curl` or `wget`, you can set the `IMPLEMENTATION` variable in `aino-config.sh` like this:

```
export IMPLEMENTATION="curl"
```
or
```
export IMPLEMENTATION="wget"
```

# Two system example

The samples directory contains a two-system integration example that can be used as-is for demoing, or as a unit test.
It contains two scripts, simulating CRM and Invoicing systems. The scripts are located in `systems` directory.

## CRM
`crm.sh` simulates a crm system that generates an address update message for invoicign system and places it into the directory `in`

## Invoicing
`invoicing.sh` periodically polls the `in` directory and processes the incoming files, logging them either as succesful (if content is valid xml) or failure (if content is not valid xml)

## Running the demo
Easiest way to run the demo is to run the `launch_demo.sh` which starts the polling script `invoicing.sh` in the background and then launches `crm.sh` to generate messages for
invoicing to process. The messages are then logged into aino.io using the API key specified in `demo/aino-config.sh`

If you run the `launch_unittest.sh`, the results will be the same as with `launch_demo.sh` but a surefire test result file is also generated
for use by continous integration systems.

# Useful tricks in Aino logging from shell scripts

This section gathers some useful tips and tricks for logging transactions to aino.io from shell script.

## XML validation
If your system has `xmllint` installed, you can use it to validate the input file (to log failure into aino.io as soon as you detect the failure instead of passing invalid data along).

You can use this function to validate a file

```
is_valid() {
    VALID=false
    xmllint "$1" >& /dev/null && VALID=true
    echo $VALID
}
```

You would check a file, say `input.xml`, like this:

```
STATUS=success
MESSAGE="Updated customer invoicing address successfully."
if [ "`is_valid input.xml`" != "true" ]; then
    STATUS=failure
    MESSAGE="Invalid customer invoicing address message"
fi
```

You could then pass the `$STATUS` and `$MESSAGE` variables into the `aino.sh` or `aino_log` invocation as status and message.

## Extracting tag values from XML
You can often skip burdensome XML parsing and opt for simpler processing when you need to extract values
from XML message for logging into Aino. Using regular unix command line tools such as `grep` and `cut` is all it takes, although
the most robust results are always gained by properly parsing the XML.

You can extract the value of a tag that from an XML input file using the function below. It first formats the XML file
so that each tag would be on a separate line, which allows us to extract the tag values using `grep` and `cut`.

```
extract_tag() {
    TAG="$1"
    xmllint --recover --format "$2" 2>/dev/null | grep "$TAG" |cut -d'>' -f2|cut -d'<' -f1|tr '\n' ' '
}
```

For example, to extract values of `<customerId>` tags from a file called `input.xml`, you would call it like this

```
CUSTOMER_IDS="`extract_tag customerId input.xml`"
```

You could then pass the values to `aino.sh` using `           --id "Customer ID" $CUSTOMER_IDS`
or for the `aino_log` function using

```
add_aino_id "Customer ID" $CUSTOMER_IDS

```

## Capturing aino.io payload and output
Sometimes, especially when debugging, it is useful to see what is being sent to aino and what is being returned in response.

You can capture the payload sent to aino.io to a file by setting the environment variable `AINO_PAYLOAD_OUT` to a filename, like this:
```
export AINO_PAYLOAD_OUT="/tmp/aino.out"
```

Similiarly you can capture the output of aino.io by setting the variable `AINO_HTTP_OUT`, like this:
```
export AINO_HTTP_OUT="/tmp/curl.out"
```

