#!/usr/bin/env bash
## author:: sadican
## description:: installation script for creating SDN research and development environment
## softwares are floodlight, mininet, openflow, wireshark, cbench
## linux distro:: Ubuntu 14.04.1 LTS x64

# fail on error
set -e

# fail on unset var usage
set -o nounset

# Globals
SDN_RAD='SDN_RAD'
INSTALL='sudo apt-get install -y'

# Functions
function floodlight {
	printf "\n%s\n" "INSTALLING DEPENDENCIES OF FLOODLIGHT"
	$INSTALL git build-essential default-jdk ant python-dev

	printf "\n%s\n" "CLONING FLOODLIGHT FROM GITHUB"
	git clone git://github.com/floodlight/floodlight.git

	printf "\n%s\n" "ENTERING FLOODLIGHT DIRECTORY"
	cd floodlight

	printf "\n%s\n" "COMPILING"
	ant

	printf "\n%s\n" "PREPARING ECLIPSE PROJECT"
	ant eclipse

	printf "\n%s\n" "GOING BACK"
	cd ..
}

function mininet {
	MININETNEW="mininet_14.04.01_LTS.sh"

	printf "\n%s\n" "INSTALLING REQUIRED PACKAGES"
	sudo apt-get install -y git build-essential

	printf "\n%s\n" "CLONING MININET FROM GITHUB"
	git clone git://github.com/mininet/mininet

	printf "\n%s\n" "COPYING MODIFIED INSTALLATION FILE"
	sudo cp $MININETNEW ./mininet/util/

	printf "\n%s\n" "GIVING EXECUTION PERMISSION TO INSTALLATION FILE"
	sudo chmod +x ./mininet/util/$MININETNEW

	printf "\n%s\n" "GETTING OWNERSHIP OF INSTALLATION FILE"
	sudo chown $USER ./mininet/util/$MININETNEW

	printf "\n%s\n" "INSTALLING MININET + OPEN VSWITCH + OPENFLOW"
	sudo ./mininet/util/$MININETNEW
}

printf "\n%s\n" "ENTERING HOME DIRECTORY"
cd $HOME

printf "\n%s\n" "CREATING SDN RESEARCH AND DEVELOPMENT (SDN_RAD) DIRECTORY"
mkdir $SDN_RAD

printf "\n%s\n" "ENTERING SDN_RAD DIRECTORY"
cd $SDN_RAD

printf "\n%s\n" "UPDATING REPOSITORIES"
sudo apt-get update

printf "\n%s\n" "UPGRADING PACKAGES"
sudo apt-get upgrade -y

#printf "\n%s\n" "INSTALLING SOME USEFUL PACKAGES THEY ARE NOT REALLY NECESSARY"
#$INSTALL nautilus-open-terminal filezilla unity-tweak-tool gnome-tweak-tool

printf "\n%s\n" "INSTALLING FLOODLIGHT"
floodlight

printf "\n%s\n" "INSTALLING MININET"
mininet
