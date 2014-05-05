#!/bin/bash

###############################################################################
#
# init_my_ubuntu - Init My Ubuntu
#
# The initial install script for Ubuntu installed from Desktop ISO
# 
# Mostly for development systems.
#
# Author  : Winny Mathew Kurian (WiZarD)
# Date    : 3rd May 2014
# Contact : WiZarD.Devel@gmail.com
# Release : v1.0
#
# Version History
###############################################################################
# Version    Release Date    Comments
###############################################################################
#
# v1.0       03-05-2014      Initial Release (For Ubuntu 14.04 Trusty Tahr)
#
# Had nothing more fun to do in my village, after seeing around :)
#
###############################################################################

# Interactive mode (just in case)
# INTERACTIVE=-y

# Simulation mode to test this script
# SIMULATION=-s

if [ "$SIMULATION" != "-s" ] ; then
    if [ `id -u` -ne 0 ] ; then
        echo You need to be root to run this script!
        exit -1
    fi
fi

OPT_FLAGS="$INTERACTIVE $SIMULATION"

# Customize what you need to install here in the list below
# The ones already here are the ones I install by default
PACKAGES="squid-deb-proxy squid-deb-proxy-client openssh-server vim mc gcc ctags lynx expect ddd doxygen meld idle git gnupg androidsdk-ddms codeblocks eclipse-platform svn-workbench xbmc aptoncd arj autoconf automake apcupsd beep boinc-client bum cabextract ccache cccc cdecl chromium-browser colorgcc colormake crash cscope cowsay dkms dosbox distcc electric-fence filezilla flex bison nasm yasm gimp gnuplot-qt dos2unix indent keepass2 kicad texlive-latex-base mono-runtime nmap nautilus-dropbox p7zip pcb-gtk pidgin pterm putty rar samba screen smartmontools subversion synaptic tree tightvncserver unrar valgrind valkyrie virtualbox-qt wvdial wireshark gvncviewer wavemon libgd2-xpm-dev openjdk-7-jdk build-essential curl libc6-dev libncurses5-dev:i386 x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc zlib1g-dev:i386"

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
NORMAL=$(tput sgr0)

apt-get update

for PACKAGE in $PACKAGES; do
    echo
    printf "%-40s" "Install $PACKAGE... "
    apt-get $OPT_FLAGS install $PACKAGE > /dev/null 2>&1
    if [ $? -eq 0 ] ; then
        printf "${GREEN}Done${NORMAL}"
    else
        printf "${RED}Failed!${NORMAL}"
    fi
done

# Configuration specific to AOSP builds
update-alternatives --config java
update-alternatives --config javac

ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so

echo
echo Done!
echo
