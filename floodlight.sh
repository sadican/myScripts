#!/usr/bin/env bash

# Fail on error
set -e

# Fail on unset var usage
set -o nounset

echo -e "\nINSTALLING REQUIRED PACKAGES\n"
sudo apt-get install -y git build-essential default-jdk ant python-dev

echo -e "\nCLONING FLOODLIGHT FROM GITHUB\n"
git clone git://github.com/floodlight/floodlight.git

echo -e "\nENTERING FLOODLIGHT DIRECTORY\n"
cd floodlight

echo -e "\nCOMPILING\n"
ant

echo -e "\nPREPARING ECLIPSE PROJECT\n"
ant eclipse

exit
