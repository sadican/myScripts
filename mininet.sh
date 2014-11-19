#!/usr/bin/env bash
## author:: sadican
## description:: mininet, openflow, cbench, wireshark installation script
## http://mininet.org/
## linux distro:: Ubuntu 14.04.1 LTS x64
## requires:: mininet_14.04.01_LTS.sh

# fail on error
set -e

# fail on unset var usage
set -o nounset

MININETNEW="mininet_14.04.01_LTS.sh"

echo -e "\nINSTALLING REQUIRED PACKAGES\n"
sudo apt-get install -y git

echo -e "\nCLONING MININET FROM GITHUB\n"
git clone git://github.com/mininet/mininet

echo -e "\nCOPY MODIFIED INSTALLATION FILE\n"
sudo cp $MININETNEW ./mininet/util/

echo -e "\nGIVE EXECUTION PERMISSION TO INSTALLATION FILE\n"
sudo chmod +x ./mininet/util/$MININETNEW

echo -e "\nGET OWNERSHIP OF INSTALLATION FILE\n"
sudo chown $USER ./mininet/util/$MININETNEW

echo -e "\nINSTALL MININET + OPEN VSWITCH + OPENFLOW + CBENCH\n"
sudo ./mininet/util/$MININETNEW

exit
