#!/bin/bash

###############################################################################
#
# init_my_ubuntu - Init My Ubuntu (IMU)
#
# The initial install script for Ubuntu installed from Desktop ISO
# 
# Mostly for development systems.
#
# Author  : Winny Mathew Kurian (WiZarD)
# Date    : 3rd May 2014
# Contact : WiZarD.Devel@gmail.com
# Release : v1.2
#
# Version History
###############################################################################
# Version    Release Date    Comments
###############################################################################
#
# v1.0       03-05-2014      Initial Release (For Ubuntu 14.04 Trusty Tahr)
# v1.1       06-05-2014      Added shutdown when done and fixed a few issues
# v1.2       07-05-2014      Segregated package depedencies
#            09-05-2014      Added DAI packages
#            10-05-2014      Added APT PPAs
#            01-05-2015      Updated packages
#            25-06-2016      Updated packages
#
# Had nothing more fun to do in my village, after seeing around :)
#
###############################################################################

# A few colors that we use
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
NORMAL=$(tput sgr0)

LOGGER=/dev/null 2>&1

# Enable/Disable Simulation
SIMULATION=0

# Enable/Disable Interactive mode
INTERACTIVE=0

# Shutdown when done
SHUTDOWN=0

# Shutdown delay
SHUTDOWN_DELAY=2

# Download directory path
DOWNLOAD_PATH=./Downloads

# Log file
LOG_FILE_PATH=./imu.log

echo
printf "${GREEN}IMU${NORMAL} (e-moo) - Init My Ubuntu"
echo
echo "Copyright (c) 2014-2016 Winny Mathew Kurian"

if [ $SIMULATION -eq 1 ] ; then
    # Simulation mode to test this script
    APT_OPT_SIMULATION="-s"
    CMD_SIMULATION=echo
elif [[ $EUID -ne 0 ]]; then
    echo
    echo "This script must be run as root!" 1>&2
    echo
    exit 1
fi

if [ $INTERACTIVE -eq 0 ] ; then
    # Non-interactive mode
    APT_OPT_INTERACTIVE="-y --force-yes"
fi

APT_OPT_FLAGS="$APT_OPT_INTERACTIVE $APT_OPT_SIMULATION"

# Customize what you need to install here in the list below
# The ones already here are the ones I install by default
APT_PACKAGES="squid-deb-proxy squid-deb-proxy-client openssh-server vim mc gcc g++ ctags lynx expect ddd doxygen meld idle git gnupg androidsdk-ddms codeblocks eclipse-platform svn-workbench xbmc aptoncd arj autoconf automake apcupsd beep boinc-client bum cabextract ccache cccc cdecl chromium-browser colorgcc colormake crash cscope cowsay dkms dosbox distcc electric-fence filezilla flex bison byobu nasm yasm gimp gnuplot-qt dos2unix indent keepass2 kicad texlive-latex-base mono-runtime
nmap nautilus-dropbox p7zip pcb-gtk pidgin pterm putty rar samba screen smartmontools subversion synaptic tree tightvncserver unrar valgrind valkyrie virtualbox-qt wvdial wireshark gvncviewer wavemon unity-tweak-tool gparted virt-manager qemu-kvm gnome-control-center lm-sensors gtkwave grub-customizer socat apt-file gitk git-gui sloccount cifs-utils minicom "

# APC UPS dependency
APT_PACKAGES=$APT_PACKAGES"libgd2-xpm-dev "

# Android Build Environment dependencies
APT_PACKAGES=$APT_PACKAGES"openjdk-7-jdk build-essential curl libc6-dev libncurses5-dev:i386 x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc zlib1g-dev:i386 phablet-tools gperf abootimg "

# Webmin dependencies
APT_PACKAGES=$APT_PACKAGES"apt-show-versions libauthen-pam-perl "

# Teamviewer dependencies
# APT_PACKAGES=$APT_PACKAGES:"lib32asound2 lib32z1 ia32-libs "

# Packages to download and install (DAI)
DAI_PACKAGES="http://jaist.dl.sourceforge.net/project/webadmin/webmin/1.801/webmin_1.801_all.deb http://download.teamviewer.com/download/teamviewer_linux_x64.deb https://launchpad.net/ubuntu-tweak/0.8.x/0.8.7/+download/ubuntu-tweak_0.8.7-1~trusty2_all.deb "

# Add all PPAs here
#APT_PPAS="ppa:tualatrix/ppa "

function runPostInstall {
    if [ "$1" == "squid-deb-proxy" ] ; then
        # Check if squid is running.
        # TODO: Make sure it is squid deb proxy
        pidof squid3 > /dev/null
        if [ $? -ne 0 ] ; then
            echo
            echo Starting squid deb proxy for caching...
            /etc/init.d/squid-deb-proxy start
        fi
    fi
}

for APT_PPA in $APT_PPAS; do
    echo
    printf "%-40s" "Adding PPA: $APT_PPA... "
    $CMD_SIMULATION add-apt-repository -y $APT_PPA > $LOGGER
    if [ $? -eq 0 ] ; then
        printf "${GREEN}Done\n${NORMAL}"
    else
        printf "${RED}Failed!\n${NORMAL}"
    fi
done

echo
echo "Updating software package list..."
#$CMD_SIMULATION apt-get update > $LOGGER

for APT_PACKAGE in $APT_PACKAGES; do
    echo
    printf "%-40s" "Install $APT_PACKAGE... "
    apt-get $APT_OPT_FLAGS install $APT_PACKAGE > $LOGGER
    if [ $? -eq 0 ] ; then
        printf "${GREEN}Done\n${NORMAL}"
        $CMD_SIMULATION runPostInstall $APT_PACKAGE
    else
        printf "${RED}Failed!\n${NORMAL}"
    fi
done

# Make a download directory
mkdir -p $DOWNLOAD_PATH

for DAI_PACKAGE in $DAI_PACKAGES; do
    PACKAGE_NAME=`basename $DAI_PACKAGE`
    if [ -e $DOWNLOAD_PATH/$PACKAGE_NAME ] ; then
        echo
        printf "Using existing package $PACKAGE_NAME..."
    else
        echo
        printf "%-40s" "Download $PACKAGE_NAME... "
        $CMD_SIMULATION wget -N -P $DOWNLOAD_PATH $DAI_PACKAGE > $LOGGER
    fi

    if [ $? -eq 0 ] ; then
        printf "${GREEN}Done\n${NORMAL}"
        echo
        printf "%-40s" "Install $DAI_PACKAGE... "
        $CMD_SIMULATION dpkg -i $DOWNLOAD_PATH/$PACKAGE_NAME > $LOGGER
        if [ $? -eq 0 ] ; then
            printf "${GREEN}Done\n${NORMAL}"
        else
            printf "${RED}Failed!\n${NORMAL}"
        fi
    else
        printf "${RED}Failed!\n${NORMAL}"
    fi
done

# Configuration specific to AOSP builds
$CMD_SIMULATION update-alternatives --config java > $LOGGER
$CMD_SIMULATION update-alternatives --config javac > $LOGGER

$CMD_SIMULATION ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so > $LOGGER

# Get repo itself
echo
echo Installing repo...
$CMD_SIMULATION mkdir ~/bin
$CMD_SIMULATION curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$CMD_SIMULATION chmod a+x ~/bin/repo

# Run custom scripts
# Wi-Fi does not connect after suspend
#echo "SUSPEND_MODULES=r8712u" > /etc/pm/config.d/config

# APC UPS daemon configuration

# Vaio brightness control
#echo "echo 1000 > /sys/class/backlight/intel_backlight/brightness" >> /etc/init.d/rc.local

# Set workgroup in /etc/samba/smb.conf

echo
echo Done!
echo

if [ $SHUTDOWN -eq 1 ] ; then
    echo System will shutdown in $SHUTDOWN_DELAY minutes.
    echo You may abort the shutdown using the command \'shutdown -c\'
    echo
    $CMD_SIMULATION shutdown -h +$SHUTDOWN_DELAY &
fi

