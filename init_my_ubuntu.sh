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
# Date    : 29th April 2026
# Contact : WiZarD.Devel@gmail.com
# Release : v1.9
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
# v1.5       30-04-2020      Made the script verbose
#                            Enabled logger
#                            Fix broken installations
# v1.6       30-04-2022      Updated for Ubuntu 22.04 Jammy
# v1.7       07-05-2022      Updated and organized packages
#                            Added Ubuntu version checks and custom script
# v1.8       XX-XX-2024      Updated and organized packages
# v1.9       29-04-2026      Updated for Ubuntu 26.04 Resolute Raccoon
#                            Added more dev packages on new setup
#
# Had nothing more fun to do in my village, after seeing around :)
#
###############################################################################

# A few colors that we use
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
NORMAL=$(tput sgr0)

#
# User configuration for IMU
#

# Enable/Disable Simulation
SIMULATION=0

# Enable/Disable Interactive mode
INTERACTIVE=0

# Shutdown when done
SHUTDOWN=0

# Shutdown delay (in minutes)
SHUTDOWN_DELAY=2

# Enable logging
LOGGING=0

# Run custom script in IMU
RUN_CUSTOM_SCRIPT=0

# Download directory path
DOWNLOAD_PATH=./Downloads

# Log file path
LOG_FILE_PATH=./imu.log

# Ubuntu release version
UBUNTU_REL_VER=`lsb_release -r | cut -d ':' -f 2 | xargs`

echo
printf "${GREEN}IMU${NORMAL} (e-moo) - Init My Ubuntu"
echo
echo "Copyright (c) 2014-2026 Winny Mathew Kurian (WiZarD)"
echo

#
# Initialize script
#
if [ $LOGGING -eq 1 ] ; then
    # Log all operation to log file
    LOGGER=$LOG_FILE_PATH
else 
    LOGGER=/dev/null
fi

START_TIME=`date` >> $LOGGER
echo "IMU started at: $START_TIME" >> $LOGGER 2>&1

if [ $SIMULATION -eq 1 ] ; then
    # Simulation mode to test this script
    APT_OPT_SIMULATION="-s"
    CMD_SIMULATION=echo
    echo
    echo "Running in simulation mode..."
elif [[ $EUID -ne 0 ]]; then
    echo
    echo "This script must be run as root!"
    echo
    exit 1
fi

if [ $INTERACTIVE -eq 0 ] ; then
    # Non-interactive mode
    # APT_OPT_INTERACTIVE="-y --force-yes"
    APT_OPT_INTERACTIVE="-y --allow-unauthenticated"
fi

APT_OPT_FLAGS="$APT_OPT_INTERACTIVE $APT_OPT_SIMULATION"

# Log Ubuntu version info
$CMD_SIMULATION lsb_release -a >> $LOGGER 2>&1

# Obselete pacakges
APT_OBSELETE_PACKAGES="ctags eclipse-platform svn-workbench bum aptoncd colorgcc valkyrie grub-customizer apt-fast "
APT_OBSELETE_PACKAGES=$APT_OBSELETE_PACKAGES"phablet-tools androidsdk-ddms python-networkx gnome-tweak-tool "

echo
echo Making packages list...
# Customize what you need to install here in the list below
# The ones already here are the ones I install by default
#
# Basic Packages
#
echo + Basic packages
APT_PACKAGES="openssh-server vim mc gcc g++ universal-ctags lynx expect ddd doxygen meld idle git gnupg codeblocks kodi arj
 autoconf automake apcupsd beep boinc-client cabextract cccc cdecl chromium-browser colormake crash cscope cowsay dkms
 dosbox distcc electric-fence filezilla flex bison byobu nasm yasm gimp gnuplot-qt dos2unix indent keepass2 kicad
 texlive-latex-base mono-runtime nmap nautilus-dropbox p7zip pcb-gtk pidgin pterm putty rar samba screen smartmontools
 subversion synaptic tree tightvncserver unrar valgrind virtualbox-qt wvdial wireshark gvncviewer wavemon unity-tweak-tool
 gparted virt-manager qemu-kvm gnome-control-center lm-sensors gtkwave socat apt-file gitk git-gui sloccount cifs-utils
 minicom iotop preload ksh tlp tlp-rdw indicator-cpufreq selinux-utils sqlite3 moreutils testdisk python3-sphinx graphviz
 graphviz texlive-xetex repo bazel-bootstrap rustc cargo systune btop powertop ncdu tmux zoxide tldr tlp tlp-rdw neofetch
 "

#
# APT Packages with PPA dependencies
#
echo + PPA dependent packages
APT_PACKAGES=$APT_PACKAGES$"apt-fast gnome-tweaks "

# Squid Packages
echo + Squid proxy packages
APT_PACKAGES=$APT_PACKAGES"squid-deb-proxy squid-deb-proxy-client "

# APC UPS dependency
echo + APC UPS dependencies
APT_PACKAGES=$APT_PACKAGES"libgd2-xpm-dev "

#
# Android Development Packages (Common)
#
echo + Android development packages
APT_PACKAGES=$APT_PACKAGES"ccache gnupg flex bison gperf build-essential zip curl tofrodos abootimg "

#
# Android Build Environment dependencies
#
echo + Ubuntu $UBUNTU_REL_VER specific

dpkg --compare-versions "$UBUNTU_REL_VER" "eq" "24.04"
if [ $? -eq 0 ] ; then
    # Ubuntu 18.04, 22.04
    APT_PACKAGES=$APT_PACKAGES"install git-core zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 libncurses5 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig "
fi

dpkg --compare-versions "$UBUNTU_REL_VER" "eq" "16.04"
if [ $? -eq 0 ] ; then
    # Ubuntu 14.04, 16.04
    APT_PACKAGES=$APT_PACKAGES"openjdk-8-jdk gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip libnss-sss:i386 "
fi

dpkg --compare-versions "$UBUNTU_REL_VER" "eq" "12.04"
if [ $? -eq 0 ] ; then
    # Ubuntu 12.04
    APT_PACKAGES=$APT_PACKAGES"openjdk-7-jdk libc6-dev libncurses5-dev:i386 x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 libgl1-mesa-dev g++-multilib mingw32 python-markdown libxml2-utils xsltproc zlib1g-dev:i386 "
fi

# Webmin dependencies
echo + Webmin dependencies
APT_PACKAGES=$APT_PACKAGES"apt-show-versions libauthen-pam-perl "

# Teamviewer dependencies
echo + Teamviewer dependencies
APT_PACKAGES=$APT_PACKAGES"lib32asound2 lib32z1 ia32-libs "

# Tweak Ubuntu dedendencies
echo + Tweak Ubuntu dependencies
APT_PACKAGES=$APT_PACKAGES"python-xdg python-aptdaemon python-aptdaemon.gtk3widgets python-defer python-compizconfig gir1.2-gconf-2.0 gir1.2-webkit-3.0 "

# Kodi dependency
echo + Kodi dependencies
APT_PACKAGES=$APT_PACKAGES"software-properties-common "

# GNOME and extra tools
echo + GNOME extra tools dependencies
APT_PACKAGES=$APT_PACKAGES"ubuntu-restricted-extras "

# Third party PPA
echo + Third party packages
APT_PACKAGES=$APT_PACKAGES"timeshift "

echo
echo Making DAI list...
# Packages to download and install (DAI)
DAI_PACKAGES="https://excellmedia.dl.sourceforge.net/project/webadmin/webmin/2.630/newkey-webmin_2.630_all.deb "
DAI_PACKAGES=$DAI_PACKAGES"https://download.teamviewer.com/download/linux/teamviewer_amd64.deb "
# DAI_PACKAGES=$DAI_PACKAGES"http://archive.getdeb.net/ubuntu/pool/apps/u/ubuntu-tweak/ubuntu-tweak_0.8.7-1~getdeb2~xenial_all.deb "

echo
echo Making DO list...
# Packages to download only (DO)
DO_PACKAGES="https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.54/bin/apache-tomcat-10.1.54.zip "
DO_PACKAGES=$DO_PACKAGES"https://updates.jenkins.io/download/war/2.562/jenkins.war "

echo
echo Making PPA list...
# Add all PPAs here
APT_PPAS="ppa:tualatrix/ppa ppa:team-xbmc/ppa "
APT_PPAS=$APT_PPAS"ppa:apt-fast/stable "
APT_PPAS=$APT_PPAS"ppa:linrunner/tlp ppa:teejee2008/ppa "
APT_PPAS=$APT_PPAS"universe "

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
    elif [ "$1" == "vim" ] ; then
        echo "No post install steps..."
    fi
}

function runPostInstall {
    echo
    echo Running post install steps...

    # Configuration specific to AOSP builds
    echo
    echo Update java links...
    $CMD_SIMULATION update-alternatives --config java >> $LOGGER 2>&1
    $CMD_SIMULATION update-alternatives --config javac >> $LOGGER 2>&1

    dpkg --compare-versions "$UBUNTU_REL_VER" "eq" "12.04"
    if [ $? -eq 0 ] ; then
        # Ununtu 10.10, 12.04
        $CMD_SIMULATION ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so >> $LOGGER 2>&1
    fi

    # Get repo itself
    echo
    echo Installing repo...
    # TODO: /root/bin need not be created
    $CMD_SIMULATION mkdir ~/bin >> $LOGGER 2>&1
    $CMD_SIMULATION curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo >> $LOGGER 2>&1
    $CMD_SIMULATION chmod a+x ~/bin/repo

    # Enable Firewall
    echo
    echo Enable Firewall...
    $CMD_SIMULATION ufw enable

    #
    # Run custom scripts
    #
    # Setup your custom scripts here
    # 
    if [ $RUN_CUSTOM_SCRIPT -eq 1 ] ; then
        echo
        echo Running custom scripts...
        # Wi-Fi does not connect after suspend
        #echo "SUSPEND_MODULES=r8712u" > /etc/pm/config.d/config

        # APC UPS daemon configuration

        # Vaio brightness control
        #echo "echo 1000 > /sys/class/backlight/intel_backlight/brightness" >> /etc/init.d/rc.local

        # Set workgroup in /etc/samba/smb.conf

        # Jenkins add key - preInstall
        # wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
    fi
}

function processDAIPackages {
    echo
    echo "Process DAI packages..."
    # Process DAI packages
    for DAI_PACKAGE in $DAI_PACKAGES; do
        PACKAGE_NAME=`basename $DAI_PACKAGE`
        if [ -e $DOWNLOAD_PATH/$PACKAGE_NAME ] ; then
            echo
            printf "Using existing package $PACKAGE_NAME... "
        else
            echo
            printf "%-40s" "Download $PACKAGE_NAME... "
            $CMD_SIMULATION wget -N -P $DOWNLOAD_PATH $DAI_PACKAGE >> $LOGGER 2>&1
        fi

        if [ $? -eq 0 ] ; then
            printf "${GREEN}Done\n${NORMAL}"
            echo
            printf "%-40s" "Install $DAI_PACKAGE... "
            $CMD_SIMULATION dpkg -i $DOWNLOAD_PATH/$PACKAGE_NAME >> $LOGGER 2>&1
            if [ $? -eq 0 ] ; then
                printf "${GREEN}Done\n${NORMAL}"
            else
                printf "${RED}Failed!\n${NORMAL}"
            fi
        else
            printf "${RED}Failed!\n${NORMAL}"
        fi
    done
}

function processDOPackages {
    echo
    echo "Process DO packages..."
    # Process DO packages
    for DO_PACKAGE in $DO_PACKAGES; do
        PACKAGE_NAME=`basename $DO_PACKAGE`
        if [ -e $DOWNLOAD_PATH/$PACKAGE_NAME ] ; then
            echo
            printf "Package already downloaded: $PACKAGE_NAME..."
        else
            echo
            printf "%-40s" "Download $PACKAGE_NAME... "
            $CMD_SIMULATION wget -N -P $DOWNLOAD_PATH $DAI_PACKAGE >> $LOGGER 2>&1
        fi
    done
}

function updatePPAs {
    echo
    echo "Updating PPAs..."
    for APT_PPA in $APT_PPAS; do
        echo
        printf "%-40s" "Adding PPA: $APT_PPA... "
        $CMD_SIMULATION add-apt-repository -y $APT_PPA >> $LOGGER 2>&1
        if [ $? -eq 0 ] ; then
            printf "${GREEN}Done\n${NORMAL}"
        else
            printf "${RED}Failed!\n${NORMAL}"
        fi
    done
}

function installPackages {
    echo
    echo "Installing software packages..."
    for APT_PACKAGE in $APT_PACKAGES; do
        echo
        printf "%-40s" "Install $APT_PACKAGE... "
        apt-get $APT_OPT_FLAGS install $APT_PACKAGE >> $LOGGER 2>&1
        if [ $? -eq 0 ] ; then
            printf "${GREEN}Done\n${NORMAL}"
            $CMD_SIMULATION runPerPostInstall $APT_PACKAGE
        else
            printf "${RED}Failed!\n${NORMAL}"
        fi
    done
}

####
#### Main
####

echo
echo "Updating software package list..."
$CMD_SIMULATION apt-get update >> $LOGGER 2>&1

# Before we start let's fix any broken installations
echo
echo "Fix broken installations (if any)..."
#
# Handle MS TTF installer EULA
#
$CMD_SIMULATION echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | $CMD_SIMULATION sudo debconf-set-selections >> $LOGGER 2>&1
$CMD_SIMULATION dpkg --configure -a --force-configure-any >> $LOGGER 2>&1
$CMD_SIMULATION apt-get --fix-broken -y install >> $LOGGER 2>&1

# Make a download directory
$CMD_SIMULATION mkdir -p $DOWNLOAD_PATH

# Download And Install (DAI)
#
# This needs to be here so that any previous aborted installation will not
# cause all installPackages from failing
processDAIPackages

# Update PPAs
updatePPAs

# Install packages
installPackages

# Download Only (DO)
processDOPackages

# Run all post install operations
$CMD_SIMULATION runPostInstall

echo
echo Done... See you after next install!
echo

END_TIME=`date` >> $LOGGER
echo "IMU completed at: $START_TIME" >> $LOGGER 2>&1

if [ $SHUTDOWN -eq 1 ] ; then
    echo System will shutdown in $SHUTDOWN_DELAY minutes.
    echo You may abort the shutdown using the command \'shutdown -c\'
    echo
    $CMD_SIMULATION shutdown -h +$SHUTDOWN_DELAY &
fi

