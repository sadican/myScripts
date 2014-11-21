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
sudo apt-get install -y git build-essential gdebi dpkg nautilus-open-terminal filezilla unity-tweak-tool gnome-tweak-tool

echo -e "\nRESET NAUTILUS\n"
sudo nautilus -q

echo -e "\nSET BASH ALIASES\n"
echo "alias update='sudo apt-get update'
alias upgrade='sudo apt-get upgrade'
alias install='sudo apt-get install'
alias autoremove='sudo apt-get autoremove'
alias autoclean='sudo apt-get autoclean'
alias reboot='sudo reboot'
alias shutdown='sudo shutdown -h now'
alias cmdx='sudo chmod +x'" > /home/$USER/.bash_aliases
source /home/$USER/.bash_aliases

echo -e "\nENABLE HIBERNATE\n"
HIBERNATE_CODE="[Re-enable hibernate by default in upower]\nIdentity=unix-user:*\nAction=org.freedesktop.upower.hibernate\nResultActive=yes\n\n[Re-enable hibernate by default in logind]\nIdentity=unix-user:*\nAction=org.freedesktop.login1.hibernate\nResultActive=yes"
echo -e $HIBERNATE_CODE > com.ubuntu.enable-hibernate.pkla
sudo mv com.ubuntu.enable-hibernate.pkla /var/lib/polkit-1/localauthority/50-local.d/

echo -e "\nHIBERNATE WHEN LID IS CLOSED\n"
echo -e "#MODIFICATION TO ACTIVE HIBERNATE WHEN LID IS CLOSED\nHandleLidSwitch=hibernate" | sudo tee --append /etc/systemd/logind.conf

echo -e "\nDOWNLOADING GOOGLE CHROME\n"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

echo -e "\nINSTALLING GOOGLE CHROME\n"
#sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo gdebi google-chrome-stable_current_amd64.deb

echo -e "\nDOWNLOADING SUBLIME TEXT 3\n"
wget http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3065_amd64.deb

echo -e "\nINSTALLING SUBLIME TEXT 3\n"
#sudo dpkg -i sublime-text_build-3065_amd64.deb
sudo gdebi sublime-text_build-3065_amd64.deb
