#! /bin/sh
./whatshell.sh


if [ "`which uname`" != "" ]; then
    echo "Operating system: `uname -a`"
fi
echo

echo "Command locations:"
echo "curl: `which curl || echo Not found`"
echo "wget: `which wget || echo Not found`"
echo "xmllint: `which xmllint || echo Not found`"
echo
echo "Versions:"
if [ "`which curl`" != "" ]; then
    curl --version
fi
if [ "`which wget`" != "" ]; then
    wget --version
fi

