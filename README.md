# Bourne Shell Agent for Aino.io

![Build status](https://circleci.com/gh/Aino-io/agent-shell.svg?style=shield&circle-token=bde6cb9153f5ed7e43f6b99a8489b1b36b0dcb83)

Download [the latest release](https://github.com/Aino-io/agent-shell/releases/)

## What is [Aino.io](http://aino.io) and what does this Agent have to do with it?

[Aino.io](http://aino.io) is an analytics and monitoring tool for integrated enterprise applications and digital business processes. Aino.io can help organizations manage, develop, and run the digital parts of their day-to-day business. Read more from our [web pages](http://aino.io).

Aino.io works by analyzing transactions between enterprise applications and other pieces of software. This Agent helps to store data about the transactions to Aino.io platform using Aino.io Data API (version 2.0). See [API documentation](http://www.aino.io/api) for detailed information about the API.

## Technical requirements
* sh compatible shell
* curl or wget
* gzip (optional, used if exists)

## Example usage

### 1. Setting AINO_HOME
You can set the `AINO_HOME` environment variable in your shell initialization file (e.g. `.bash_profile`), or at the start of your script.
For example, if you had the aino scripts in `/opt/aino`, you could do at the start of your script:

```
export AINO_HOME="/opt/aino"
```

### 2. Modify aino-config.sh
Configure your API key in the `aino-config.sh`. The file should look like this:

```
export AINO_API_KEY="<your api key here>"
```

You can place the `aino-config.sh` into the `AINO_HOME` directory in which case it will be found automatically. You can also
tell the `aino.sh` script where it is located using the `--config` switch.

If you prefer using the function to invoke aino logging, you can include the config file in your script using the . method to include it.

```
. /location/to/aino-config.sh
```

### 2. Send a request to Aino.io:

#### Minimal example (only required fields)

```
${AINO_HOME}/aino.sh --from "Source system" --to "Target system" --status "success" \
           --config /path/to/aino-config.sh
```

#### Full example

```
${AINO_HOME}/aino.sh --from "Source system" --to "Target system" --status "success" \
		  --message "Message describing what happened." \
          --payload "Type of data transferred" --operation "Operation (business process) name" \
           --flowid "Identifier for this transaction. Leave empty to generate automatically " \
           --id "Some Identifier" "abcc" "dddef" "xyzzy" \
           --id "Another Identifier" "123" "456" "789" \
           --config /path/to/aino-config.sh
```

Note that when identifiers are passed with the `--id` flag, the first string is interpreted as the human-readable type or name of the identifier, and the following list of strings are interpreted as the actual identifiers.

You can use the functions from `aino-libary.sh` to generate the request or use the `aino.sh` script

# What to use as flow ID
The flow ID, also known as correlation ID or correlation key is an identifier that allows aino
to group several transactions into a single sequence. This enables the use of advanced
aino.io features that are coming later.

In shell script integrations it may be hard to retain the same correlation / flow id for the duration
of the whole processing chain. One possible value here would be the filename, if it is random and
stays the same in all the programs that process the file.

By default it can be left empty, in which case the aino.io shell agent will generate it for you.

If you have a script that logs multiple transactions into aino.io for the same file, then you will want to
call
```
init_flow_id
```
when you begin new sequence of transactions. This will ensure that the same flow id is passed for each call into aino.io
and ensure that the relevant transactions are grouped into a sequence.

To have `init_flow_id` function available in your script, include aino.io function library into your script using
 ```
 . ${AINO_HOME}/aino-library.sh
 ```
## Debugging

If you wish to see what the aino client is doing, pass the `--verbose` flag into the aino.sh invocation.

### Tested environments

Agent shell has been tested in following environments:
- Fedora 23:
	- GNU bash, version 4.3.42(1)-release (x86_64-redhat-linux-gnu)
	- curl 7.43.0 (x86_64-redhat-linux-gnu) libcurl/7.43.0 NSS/3.22 Basic ECC zlib/1.2.8 libidn/1.32 libssh2/1.6.0 nghttp2/1.7.1
- Ubuntu 12.04:
  	- Dash, version 0.5.7
  	- curl 7.22.0 (x86_64-pc-linux-gnu) libcurl/7.22.0 OpenSSL/1.0.1 zlib/1.2.3.4 libidn/1.23 librtmp/2.3
- Mac OS X 10.11.3:
	- GNU bash
	- KSH

## Contributing

### Contributors

- [Kalle Pahajoki](https://github.com/kallepahajoki)
- [Jussi Mikkonen](https://github.com/jussi-mikkonen)
- [Dani Pärnänen](https://github.com/dparnane)
- [Esa Heikkinen](https://github.com/esaheikkinen)
- [Erno Lahtinen](https://github.com/ernolahtinen)
- [Ville Harvala](https://github.com/vharvala)

## [License](LICENSE)

Copyright &copy; 2016 [Aino.io](http://aino.io). Licensed under the [Apache 2.0 License](LICENSE).
