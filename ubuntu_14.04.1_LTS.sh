#!/usr/bin/env bash

# Fail on error
set -e

# Fail on unset var usage
set -o nounset

echo "UPDATING REPOSITORIES..."
sudo apt-get update

echo "UPGRADING PACKAGES..."
sudo apt-get upgrade

echo "INSTALLING NEW PACKAGES..."
sudo apt-get install -y git build-essential default-jdk ant python-dev nautilus-open-terminal filezilla unity-tweak-tool gnome-tweak-tool
