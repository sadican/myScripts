#!/usr/bin/env bash
## author:: sadican
## description:: some stuffs after installing new Ubuntu 14.04.1 LTS

# fail on error
set -e

# fail on unset var usage
set -o nounset

echo -e "\nUPDATING REPOSITORIES\n"
sudo apt-get update

echo -e "\nUPGRADING PACKAGES\n"
sudo apt-get upgrade

echo -e "\nINSTALLING NEW PACKAGES\n"
sudo apt-get install -y git build-essential default-jdk ant python-dev nautilus-open-terminal filezilla unity-tweak-tool gnome-tweak-tool
