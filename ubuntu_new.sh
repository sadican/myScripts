#!/usr/bin/env bash
## author:: sadican
## description:: installation and adjustments after installing new Ubuntu 14.04.1 LTS
## linux distro:: Ubuntu 14.04.1 LTS x64

# fail on error
set -e

# fail on unset var usage
set -o nounset

echo -e "\nUPDATING REPOSITORIES\n"
sudo apt-get update

echo -e "\nUPGRADING PACKAGES\n"
sudo apt-get upgrade

echo -e "\nINSTALLING NEW PACKAGES\n"
sudo apt-get install -y git build-essential dpkg default-jdk ant python-dev nautilus-open-terminal filezilla unity-tweak-tool gnome-tweak-tool

echo -e "\nDOWNLOADING GOOGLE CHROME\n"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

echo -e "\nINSTALLING GOOGLE CHROME\n"
sudo dpkg -i google-chrome-stable_current_amd64.deb

echo -e "\nDOWNLOADING SUBLIME TEXT 3\n"
wget http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3065_amd64.deb

echo -e "\nINSTALLING SUBLIME TEXT 3\n"
sudo dpkg -i sublime-text_build-3065_amd64.deb
