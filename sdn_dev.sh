#!/usr/bin/env bash
## author:: sadican
## description:: installation script for creating SDN research and development environment
## softwares are floodlight, mininet, openflow, wireshark, cbench
## linux distro:: Ubuntu 14.04.1 LTS x64

# fail on error
set -e

# fail on unset var usage
set -o nounset

# SDN Dev Directory Name
SDN_RAD='SDN_RAD'

# Attempt to identify Linux release
DIST=Unknown
RELEASE=Unknown
CODENAME=Unknown
ARCH=`uname -m`
if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; fi
if [ "$ARCH" = "i686" ]; then ARCH="i386"; fi

test -e /etc/debian_version && DIST="Debian"
grep Ubuntu /etc/lsb-release &> /dev/null && DIST="Ubuntu"
if [ "$DIST" = "Ubuntu" ] || [ "$DIST" = "Debian" ]; then
	install='sudo apt-get -y install'
	remove='sudo apt-get -y remove'
	pkginst='sudo dpkg -i'
	# Prereqs for this script
	if ! which lsb_release &> /dev/null; then
	$install lsb-release
	fi
else
	echo "NOT UBUNTU!"
	exit 1
fi

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

printf "\n%s\n" "INSTALLING DEPENDENCIES OF FLOODLIGHT"
$install git build-essential default-jdk ant python-dev

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

echo -e "\nCLONING MININET FROM GITHUB\n"
git clone git://github.com/mininet/mininet

# Get directory containing mininet folder
MININET_DIR="$( pwd -P )"

# Set up build directory, which by default is the working directory
#  unless the working directory is a subdirectory of mininet,
#  in which case we use the directory containing mininet
BUILD_DIR="$(pwd -P)"
case $BUILD_DIR in
  $MININET_DIR/*) BUILD_DIR=$MININET_DIR;; # currect directory is a subdirectory
*) BUILD_DIR=$BUILD_DIR;;
esac

# Location of CONFIG_NET_NS-enabled kernel(s)
KERNEL_LOC=http://www.openflow.org/downloads/mininet

if which lsb_release &> /dev/null; then
	DIST=`lsb_release -is`
	RELEASE=`lsb_release -rs`
	CODENAME=`lsb_release -cs`
fi
echo "Detected Linux distribution: $DIST $RELEASE $CODENAME $ARCH"

# Kernel params

KERNEL_NAME=`uname -r`
KERNEL_HEADERS=kernel-headers-${KERNEL_NAME}

if ! echo $DIST | egrep 'Ubuntu|Debian'; then
	echo "Install.sh currently only supports Ubuntu and Debian."
	exit 1
fi

# More distribution info
DIST_LC=`echo $DIST | tr [A-Z] [a-z]` # as lower case

# Determine whether version $1 >= version $2
# usage: if version_ge 1.20 1.2.3; then echo "true!"; fi
function version_ge {
	# sort -V sorts by *version number*
	latest=`printf "$1\n$2" | sort -V | tail -1`
	# If $1 is latest version, then $1 >= $2
	[ "$1" == "$latest" ]
}

# Kernel Deb pkg to be removed:
KERNEL_IMAGE_OLD=linux-image-2.6.26-33-generic

DRIVERS_DIR=/lib/modules/${KERNEL_NAME}/kernel/drivers/net

OVS_RELEASE=2.3.0
OVS_PACKAGE_LOC=https://github.com/downloads/mininet/mininet
OVS_BUILDSUFFIX=-ignore # was -2
OVS_PACKAGE_NAME=ovs-$OVS_RELEASE-core-$DIST_LC-$RELEASE-$ARCH$OVS_BUILDSUFFIX.tar
OVS_TAG=v$OVS_RELEASE

OF13_SWITCH_REV=${OF13_SWITCH_REV:-""}

function kernel {
	echo "Install Mininet-compatible kernel if necessary"
	sudo apt-get update
	$install linux-image-$KERNEL_NAME
}

function kernel_clean {
	echo "Cleaning kernel..."

	# To save disk space, remove previous kernel
	if ! $remove $KERNEL_IMAGE_OLD; then
		echo $KERNEL_IMAGE_OLD not installed.
	fi

	# Also remove downloaded packages:
	rm -f $HOME/linux-headers-* $HOME/linux-image-*
}

# Install Mininet deps
function mn_deps {
	echo "Installing Mininet dependencies"
	if [ "$DIST" = "Fedora" ]; then
		$install gcc make socat psmisc xterm openssh-clients iperf \
		iproute telnet python-setuptools libcgroup-tools \
		ethtool help2man pyflakes pylint python-pep8
	else
		$install gcc make socat psmisc xterm ssh iperf iproute telnet \
		python-setuptools cgroup-bin ethtool help2man \
		pyflakes pylint pep8
	fi

	echo "Installing Mininet core"
	pushd $MININET_DIR/mininet
	sudo make install
	popd
}

# The following will cause a full OF install, covering:
# -user switch
# The instructions below are an abbreviated version from
# http://www.openflowswitch.org/wk/index.php/Debian_Install
function of {
	echo "Installing OpenFlow reference implementation..."
	cd $BUILD_DIR
	$install autoconf automake libtool make gcc
	$install git-core autotools-dev pkg-config libc6-dev
	git clone git://openflowswitch.org/openflow.git
	cd $BUILD_DIR/openflow

	# Patch controller to handle more than 16 switches
	patch -p1 < $MININET_DIR/mininet/util/openflow-patches/controller.patch

	# Resume the install:
	./boot.sh
	./configure
	make
	sudo make install
	cd $BUILD_DIR
}

function of13 {
	echo "Installing OpenFlow 1.3 soft switch implementation..."
	cd $BUILD_DIR/
	$install  git-core autoconf automake autotools-dev pkg-config \
	make gcc g++ libtool libc6-dev cmake libpcap-dev libxerces-c2-dev  \
	unzip libpcre3-dev flex bison libboost-dev

	if [ ! -d "ofsoftswitch13" ]; then
		git clone https://github.com/CPqD/ofsoftswitch13.git
		if [[ -n "$OF13_SWITCH_REV" ]]; then
			cd ofsoftswitch13
			git checkout ${OF13_SWITCH_REV}
			cd ..
		fi
	fi

	# Install netbee
	NBEESRC="nbeesrc-jan-10-2013"
	NBEEURL=${NBEEURL:-http://www.nbee.org/download/}
	wget -nc ${NBEEURL}${NBEESRC}.zip
	unzip ${NBEESRC}.zip
	cd ${NBEESRC}/src
	cmake .
	make
	cd $BUILD_DIR/
	sudo cp ${NBEESRC}/bin/libn*.so /usr/local/lib
	sudo ldconfig
	sudo cp -R ${NBEESRC}/include/ /usr/

	# Resume the install:
	cd $BUILD_DIR/ofsoftswitch13
	./boot.sh
	./configure
	make
	sudo make install
	cd $BUILD_DIR
}

function install_wireshark {
	if ! which wireshark; then
		echo "Installing Wireshark"
		if [ "$DIST" = "Fedora" ]; then
			$install wireshark wireshark-gnome
		else
			$install wireshark tshark
		fi
	fi

	# Copy coloring rules: OF is white-on-blue:
	echo "Optionally installing wireshark color filters"
	mkdir -p $HOME/.wireshark
	cp -n $MININET_DIR/mininet/util/colorfilters $HOME/.wireshark

	echo "Checking Wireshark version"
	WSVER=`wireshark -v | egrep -o '[0-9\.]+' | head -1`
	if version_ge $WSVER 1.12; then
		echo "Wireshark version $WSVER >= 1.12 - returning"
		return
	fi

	echo "Cloning LoxiGen and building openflow.lua dissector"
	cd $BUILD_DIR
	git clone https://github.com/floodlight/loxigen.git
	cd loxigen
	make wireshark

	# Copy into plugin directory
	# libwireshark0/ on 11.04; libwireshark1/ on later
	WSDIR=`find /usr/lib -type d -name 'libwireshark*' | head -1`
	WSPLUGDIR=$WSDIR/plugins/
	PLUGIN=loxi_output/wireshark/openflow.lua
	sudo cp $PLUGIN $WSPLUGDIR
	echo "Copied openflow plugin $PLUGIN to $WSPLUGDIR"

	cd $BUILD_DIR
}

function remove_ovs {
	pkgs=`dpkg --get-selections | grep openvswitch | awk '{ print $1;}'`
	echo "Removing existing Open vSwitch packages:"
	echo $pkgs
	if ! $remove $pkgs; then
		echo "Not all packages removed correctly"
	fi
	# For some reason this doesn't happen
	if scripts=`ls /etc/init.d/*openvswitch* 2>/dev/null`; then
		echo $scripts
		for s in $scripts; do
			s=$(basename $s)
			echo SCRIPT $s
			sudo service $s stop
			sudo rm -f /etc/init.d/$s
			sudo update-rc.d -f $s remove
		done
	fi
	echo "Done removing OVS"
}

# Install Open vSwitch specific version Ubuntu package
function ubuntuOvs {
	echo "Creating and Installing Open vSwitch packages..."

	OVS_SRC=$BUILD_DIR/openvswitch
	OVS_TARBALL_LOC=http://openvswitch.org/releases

	if [ "$DIST" = "Ubuntu" ] && version_ge $RELEASE 12.04; then
		rm -rf $OVS_SRC
		mkdir -p $OVS_SRC
		cd $OVS_SRC

		if wget $OVS_TARBALL_LOC/openvswitch-$OVS_RELEASE.tar.gz 2> /dev/null; then
			tar xzf openvswitch-$OVS_RELEASE.tar.gz
		else
			echo "Failed to find OVS at $OVS_TARBALL_LOC/openvswitch-$OVS_RELEASE.tar.gz"
			cd $BUILD_DIR
			return
		fi

		# Remove any old packages
		$remove openvswitch-common openvswitch-datapath-dkms openvswitch-controller \
		openvswitch-pki openvswitch-switch
		remove_ovs

		# Get build deps
		$install build-essential fakeroot debhelper autoconf automake libssl-dev \
		pkg-config bzip2 openssl python-all procps python-qt4 \
		python-zopeinterface python-twisted-conch dkms

		# Build OVS
		cd $BUILD_DIR/openvswitch/openvswitch-$OVS_RELEASE
		DEB_BUILD_OPTIONS='parallel=4 nocheck' fakeroot debian/rules binary
		cd ..
		$pkginst openvswitch-common_$OVS_RELEASE*.deb openvswitch-datapath-dkms_$OVS_RELEASE*.deb \
		openvswitch-pki_$OVS_RELEASE*.deb openvswitch-switch_$OVS_RELEASE*.deb
		if $pkginst openvswitch-controller_$OVS_RELEASE*.deb; then
			echo "Ignoring error installing openvswitch-controller"
		fi

		modinfo openvswitch
		sudo ovs-vsctl show
		# Switch can run on its own, but
		# Mininet should control the controller
		# This appears to only be an issue on Ubuntu/Debian
		if sudo service openvswitch-controller stop; then
			echo "Stopped running controller"
		fi
		if [ -e /etc/init.d/openvswitch-controller ]; then
			sudo update-rc.d openvswitch-controller disable
		fi
	else
		echo "Failed to install Open vSwitch.  OS must be Ubuntu >= 12.04"
		cd $BUILD_DIR
		return
	fi
}

function remove_ovs {
	pkgs=`dpkg --get-selections | grep openvswitch | awk '{ print $1;}'`
	echo "Removing existing Open vSwitch packages:"
	echo $pkgs
	if ! $remove $pkgs; then
		echo "Not all packages removed correctly"
	fi
	# For some reason this doesn't happen
	if scripts=`ls /etc/init.d/*openvswitch* 2>/dev/null`; then
		echo $scripts
		for s in $scripts; do
			s=$(basename $s)
			echo SCRIPT $s
			sudo service $s stop
			sudo rm -f /etc/init.d/$s
			sudo update-rc.d -f $s remove
		done
	fi
	echo "Done removing OVS"
}

# Install OFtest
function oftest {
	echo "Installing oftest..."

	# Install deps:
	$install tcpdump python-scapy

	# Install oftest:
	cd $BUILD_DIR/
	git clone git://github.com/floodlight/oftest
}

# Install cbench
function cbench {
	echo "Installing cbench..."
	$install libsnmp-dev libpcap-dev libconfig-dev
	cd $BUILD_DIR/
	git clone git://gitosis.stanford.edu/oflops.git
	cd oflops
	sh boot.sh || true # possible error in autoreconf, so run twice
	sh boot.sh
	./configure --with-openflow-src-dir=$BUILD_DIR/openflow
	make
	sudo make install || true # make install fails; force past this
}

# remove avahi
$remove avahi-daemon

# install tcpdump
$install tcpdump

# disable IPv6
if ! grep 'disable IPv6' /etc/sysctl.conf; then
echo 'Disabling IPv6'
echo '
# Mininet: disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1' | sudo tee -a /etc/sysctl.conf > /dev/null
fi

OF_VERSION=1.0
kernel
mn_deps
of
install_wireshark
ubuntuOvs
oftest
cbench
