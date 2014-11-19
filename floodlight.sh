#!/usr/bin/env bash
## author:: sadican
## description:: installation script for Floodlight controller
## https://github.com/floodlight/floodlight
## linux distro:: Ubuntu 14.04.1 LTS x64

# fail on error
set -e

# fail on unset var usage
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
