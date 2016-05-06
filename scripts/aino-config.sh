# This is the configuration file for Aino.io Bourne shell client
# This file should be customized for each user.

# This is the API key used to communicate with Aino instance. API keys can be managed through the aino.io admin interfaces
export AINO_API_KEY="<your-api-key-here>"

# Other variables that can be set here: IMPLEMENTATION, AINO_URL, AINO_DISABLE_GZIP

# Disable gzipping of the payload. Gzipping is enabled by default.
#export AINO_DISABLE_GZIP=true

# $IMPLEMENTATION defaults to 'autodetect', which first tries to
# use curl and then wget. You can force the use of curl or wget here.
#export IMPLEMENTATION="wget"
#export IMPLEMENTATION="curl"