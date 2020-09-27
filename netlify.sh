#!/bin/sh

SOUPAULT_VERSION="2.0.0"

if [ -z "${SOUPAULT_VERSION}" ]; then
    echo "Error: soupault version is undefined, cannot decide what to download"
    exit 1
fi

echo "Downloading and unpacking soupault"
wget https://files.baturin.org/software/soupault/$SOUPAULT_VERSION/soupault-$SOUPAULT_VERSION-linux-x86_64.tar.gz
if [ $? != 0 ]; then
    echo "Error: failed to download soupault."
    exit 1
fi


tar xvf soupault-$SOUPAULT_VERSION-linux-x86_64.tar.gz

./soupault-$SOUPAULT_VERSION-linux-x86_64/soupault
