#!/usr/bin/env bash
## author:: sadican
## description:: Eclipse Luna installation script under opt folder
## linux distro:: Ubuntu 14.04.1 LTS x64

# fail on error
set -e

# fail on unset var usage
set -o nounset

ECLIPSE="eclipse-standard-luna-SR1-linux-gtk-x86_64"
ECLIPSELUNA="eclipse_luna"
ECLIPSELAUNCHERCODE="[Desktop Entry]\nName=Eclipse Luna\nType=Application\nExec=/opt/$ECLIPSELUNA/eclipse\nTerminal=false\nIcon=/opt/$ECLIPSELUNA/icon.xpm\nComment=Integrated Development Environment\nNoDisplay=false\nCategories=Development;IDE;\nName[en]=Eclipse Luna"

echo -e "\nDOWNLOADING ECLIPSE LUNA\n"
wget http://developer.eclipsesource.com/technology/epp/luna/$ECLIPSE.tar.gz

echo -e "\nEXTRACTING COMPRESSED FILE\n"
tar -zxvf $ECLIPSE.tar.gz

echo -e "\nRENAMING DIRECTORY\n"
mv "eclipse" $ECLIPSELUNA

echo -e "\nMOVING ECLIPSE TO OPT DIRECTORY\n"
sudo mv $ECLIPSELUNA /opt/

echo -e "\nCREATING LAUNCHER\n"
echo -e $ECLIPSELAUNCHERCODE > $ECLIPSELUNA.desktop

echo -e "\nMOVING LAUNCHER to /usr/share/applications/\n"
sudo mv $ECLIPSELUNA.desktop /usr/share/applications/

echo -e "\nGIVING EXECUTION PERMISSON TO LAUNCHER\n"
sudo chmod +x /usr/share/applications/$ECLIPSELUNA.desktop

exit
