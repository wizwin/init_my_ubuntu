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
# Release : v1.4
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
#            30-01-2017      Updated for Ubuntu Xenial Xerus
#            09-12-2017      Updated packages
# v1.3       29-05-2018      Updated packages
# v1.4       28-04-2020      Covid-19 Lockdown updates for
#                            Ubuntu 20.04 Focal Fossa
#
# Had nothing more fun to do in my village, after seeing around :)
#
###############################################################################

# A few colors that we use
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
NORMAL=$(tput sgr0)

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

LOGGER=/dev/null 2>&1

echo
printf "${GREEN}IMU${NORMAL} (e-moo) - Init My Ubuntu"
echo
echo "Copyright (c) 2014-2020 Winny Mathew Kurian (WiZarD)"

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
    # APT_OPT_INTERACTIVE="-y --force-yes"
    APT_OPT_INTERACTIVE="-y --allow-unauthenticated"
fi

APT_OPT_FLAGS="$APT_OPT_INTERACTIVE $APT_OPT_SIMULATION"

# Customize what you need to install here in the list below
# The ones already here are the ones I install by default
APT_PACKAGES="squid-deb-proxy squid-deb-proxy-client openssh-server vim mc gcc g++ ctags lynx expect ddd doxygen meld idle git gnupg codeblocks eclipse-platform svn-workbench kodi aptoncd arj autoconf automake apcupsd beep boinc-client bum cabextract cccc cdecl chromium-browser colorgcc colormake crash cscope cowsay dkms dosbox distcc electric-fence filezilla flex bison byobu nasm yasm gimp gnuplot-qt dos2unix indent keepass2 kicad texlive-latex-base mono-runtime nmap nautilus-dropbox p7zip pcb-gtk pidgin pterm putty rar samba screen smartmontools subversion synaptic tree tightvncserver unrar valgrind valkyrie virtualbox-qt wvdial wireshark gvncviewer wavemon unity-tweak-tool gparted virt-manager qemu-kvm gnome-control-center lm-sensors gtkwave grub-customizer socat apt-file gitk git-gui sloccount cifs-utils minicom iotop preload ksh apt-fast tlp tlp-rdw indicator-cpufreq "

# APC UPS dependency
APT_PACKAGES=$APT_PACKAGES"libgd2-xpm-dev "

#
#Android Development Packages (Common)
APT_PACKAGES=$APT_PACKAGES"ccache gnupg flex bison gperf build-essential zip curl tofrodos phablet-tools abootimg androidsdk-ddms python-networkx "
#
# Android Build Environment dependencies
#
# Ubuntu 14.04, 16.04
APT_PACKAGES=$APT_PACKAGES"openjdk-8-jdk gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip libnss-sss:i386 "
#
# Ubuntu 12.04
#APT_PACKAGES=$APT_PACKAGES"openjdk-7-jdk libc6-dev libncurses5-dev:i386 x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 libgl1-mesa-dev g++-multilib mingw32 python-markdown libxml2-utils xsltproc zlib1g-dev:i386 "
#

# Webmin dependencies
APT_PACKAGES=$APT_PACKAGES"apt-show-versions libauthen-pam-perl "

# Teamviewer dependencies
APT_PACKAGES=$APT_PACKAGES:"lib32asound2 lib32z1 ia32-libs "

# Tweak Ubuntu dedendencies
APT_PACKAGES=$APT_PACKAGES:"python-xdg python-aptdaemon python-aptdaemon.gtk3widgets python-defer python-compizconfig gir1.2-gconf-2.0 gir1.2-webkit-3.0 "

# Kodi dependency
APT_PACKAGES=$APT_PACKAGES"software-properties-common "

# GNOME and extra tools
APT_PACKAGES=$APT_PACKAGES"gnome-tweak-tool ubuntu-restricted-extras "

# Third party PPA
APT_PACKAGES=$APT_PACKAGES"timeshift "

# Packages to download and install (DAI)
DAI_PACKAGES="http://prdownloads.sourceforge.net/webadmin/webmin_1.941_all.deb http://download.teamviewer.com/download/teamviewer_linux_x64.deb http://archive.getdeb.net/ubuntu/pool/apps/u/ubuntu-tweak/ubuntu-tweak_0.8.7-1~getdeb2~xenial_all.deb "

# Packages to download only (DO)
DO_PACKAGES="http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.34/bin/apache-tomcat-9.0.34.zip https://updates.jenkins-ci.org/download/war/2.234/jenkins.war "

# Add all PPAs here
APT_PPAS="ppa:tualatrix/ppa ppa:team-xbmc/ppa ppa:apt-fast/stable ppa:linrunner/tlp ppa:teejee2008/ppa "

function runPerPostInstall {
    if [ "$1" == "squid-deb-proxy" ] ; then
        # Check if squid is running.
        # TODO: Make sure it is squid deb proxy
        pidof squid3 > /dev/null
        if [ $? -ne 0 ] ; then
            echo
            echo Starting squid deb proxy for caching...
            #/etc/init.d/squid-deb-proxy start
        fi
    fi
}

function runPostInstall {
    # Configuration specific to AOSP builds
    $CMD_SIMULATION update-alternatives --config java > $LOGGER
    $CMD_SIMULATION update-alternatives --config javac > $LOGGER
    #
    # Ununtu 10.10, 12.04
    #$CMD_SIMULATION ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so > $LOGGER
    #

    # Get repo itself
    echo
    echo Installing repo...
    $CMD_SIMULATION mkdir ~/bin
    $CMD_SIMULATION curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    $CMD_SIMULATION chmod a+x ~/bin/repo

    # Enable Firewall
    $CMD_SIMULATION ufw enable

    # Run custom scripts
    # Wi-Fi does not connect after suspend
    #echo "SUSPEND_MODULES=r8712u" > /etc/pm/config.d/config

    # APC UPS daemon configuration

    # Vaio brightness control
    #echo "echo 1000 > /sys/class/backlight/intel_backlight/brightness" >> /etc/init.d/rc.local

    # Set workgroup in /etc/samba/smb.conf
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
$CMD_SIMULATION apt-get update > $LOGGER

for APT_PACKAGE in $APT_PACKAGES; do
    echo
    printf "%-40s" "Install $APT_PACKAGE... "
    apt-get $APT_OPT_FLAGS install $APT_PACKAGE > $LOGGER
    if [ $? -eq 0 ] ; then
        printf "${GREEN}Done\n${NORMAL}"
        $CMD_SIMULATION runPerPostInstall $APT_PACKAGE
    else
        printf "${RED}Failed!\n${NORMAL}"
    fi
done

# Make a download directory
mkdir -p $DOWNLOAD_PATH

# Process DO packages
for DO_PACKAGE in $DO_PACKAGES; do
    PACKAGE_NAME=`basename $DO_PACKAGE`
    if [ -e $DOWNLOAD_PATH/$PACKAGE_NAME ] ; then
        echo
        printf "Package already downloaded: $PACKAGE_NAME..."
    else
        echo
        printf "%-40s" "Download $PACKAGE_NAME... "
        $CMD_SIMULATION wget -N -P $DOWNLOAD_PATH $DAI_PACKAGE > $LOGGER
    fi
done

# Process DAI packages
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

# Run all post install operations
$CMD_SIMULATION runPerPostInstall

echo
echo Done... See you after next install!
echo

if [ $SHUTDOWN -eq 1 ] ; then
    echo System will shutdown in $SHUTDOWN_DELAY minutes.
    echo You may abort the shutdown using the command \'shutdown -c\'
    echo
    $CMD_SIMULATION shutdown -h +$SHUTDOWN_DELAY &
fi

