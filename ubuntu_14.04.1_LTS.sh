#!/usr/bin/env bash

# Fail on error
set -e

# Fail on unset var usage
set -o nounset

echo -e "\nUPDATING REPOSITORIES\n"
sudo apt-get update

echo -e "\nUPGRADING PACKAGES\n"
sudo apt-get upgrade

echo -e "\nINSTALLING NEW PACKAGES\n"
sudo apt-get install -y git build-essential default-jdk ant python-dev nautilus-open-terminal filezilla unity-tweak-tool gnome-tweak-tool
