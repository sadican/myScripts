#!/usr/bin/env bash

# Fail on error
set -e

# Fail on unset var usage
set -o nounset

echo "\nINSTALLING REQUIRED PACKAGES..."
sudo apt-get install -y git build-essential default-jdk ant python-dev

echo "CLONING FLOODLIGHT FROM GITHUB..."
git clone git://github.com/floodlight/floodlight.git

echo "ENTERING FLOODLIGHT DIRECTORY..."
cd floodlight

echo "COMPILING..."
ant

echo "PREPARING ECLIPSE PROJECT..."
ant eclipse

exit
