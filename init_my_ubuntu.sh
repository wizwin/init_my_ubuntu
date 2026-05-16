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
# Release : v2.0
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
# v2.0       16-05-2026      Added execution report and improved logging
#                            Added retry mechanism for fixing broken installations
#                            Added URL reachability checks for downloads and PPAs
#                            Added checksum verification for downloads
#                            Added execution time tracking and reporting
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
LOGGING=1

# Run custom script in IMU
RUN_CUSTOM_SCRIPT=0

# Download directory path
DOWNLOAD_PATH=./Downloads

# Log file path
LOG_FILE_PATH=./imu.log

# Ubuntu release version
UBUNTU_REL_VER=`lsb_release -r | cut -d ':' -f 2 | xargs`
UBUNTU_CODENAME=`lsb_release -cs | xargs`

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
    export DEBIAN_FRONTEND=noninteractive
fi

APT_OPT_FLAGS="$APT_OPT_INTERACTIVE $APT_OPT_SIMULATION"

# Log Ubuntu version info
$CMD_SIMULATION lsb_release -a >> $LOGGER 2>&1

# Obselete pacakges
APT_OBSELETE_PACKAGES=(
    "ctags" "eclipse-platform" "svn-workbench" "bum" "aptoncd" "colorgcc" "valkyrie" "grub-customizer" "apt-fast"
    "phablet-tools" "androidsdk-ddms" "python-networkx" "gnome-tweak-tool" "pcb-gtk"
)

echo
echo Making packages list...
# Customize what you need to install here in the list below
# The ones already here are the ones I install by default
#
# Basic Packages
#
echo + Basic packages
APT_PACKAGES=(
    "openssh-server" "vim" "mc" "gcc" "g++" "universal-ctags" "lynx" "expect" "ddd" "doxygen" "meld" "idle" "git" "gnupg" "codeblocks" "kodi" "arj"
    "autoconf" "automake" "apcupsd" "beep" "boinc-client" "cabextract" "cccc" "cdecl" "chromium-browser" "colormake" "crash" "cscope" "cowsay" "dkms"
    "dosbox" "distcc" "electric-fence" "filezilla" "flex" "bison" "byobu" "nasm" "yasm" "gimp" "gnuplot-qt" "dos2unix" "indent" "keepass2" "kicad"
    "texlive-latex-base" "mono-runtime" "nmap" "nautilus-dropbox" "p7zip" "pidgin" "pterm" "putty" "rar" "samba" "screen" "smartmontools"
    "subversion" "synaptic" "tree" "tightvncserver" "unrar" "valgrind" "virtualbox-qt" "wvdial" "wireshark" "gvncviewer" "wavemon" "unity-tweak-tool"
    "gparted" "virt-manager" "qemu-kvm" "gnome-control-center" "lm-sensors" "gtkwave" "socat" "apt-file" "gitk" "git-gui" "sloccount" "cifs-utils"
    "minicom" "iotop" "preload" "ksh" "tlp" "tlp-rdw" "indicator-cpufreq" "selinux-utils" "sqlite3" "moreutils" "testdisk" "python3-sphinx" "graphviz"
    "texlive-xetex" "repo" "bazel-bootstrap" "rustc" "cargo" "systune" "btop" "powertop" "ncdu" "tmux" "zoxide"
)

#
# APT Packages with PPA dependencies
#
echo + PPA dependent packages
APT_PACKAGES+=("apt-fast" "gnome-tweaks")

# Squid Packages
echo + Squid proxy packages
APT_PACKAGES+=("squid-deb-proxy" "squid-deb-proxy-client")

# APC UPS dependency
echo + APC UPS dependencies
APT_PACKAGES+=("libgd2-xpm-dev")

#
# Android Development Packages (Common)
#
echo + Android development packages
APT_PACKAGES+=("ccache" "gnupg" "flex" "bison" "gperf" "build-essential" "zip" "curl" "tofrodos" "abootimg")

#
# Android Build Environment dependencies
#
echo + Ubuntu $UBUNTU_REL_VER specific

if dpkg --compare-versions "$UBUNTU_REL_VER" "ge" "24.04"; then
    # Ubuntu 24.04 and above (including 26.04)
    APT_PACKAGES+=("git-core" "zlib1g-dev" "gcc-multilib" "g++-multilib" "libc6-dev-i386" "libncurses5" "lib32ncurses5-dev" "x11proto-core-dev" "libx11-dev" "lib32z1-dev" "libgl1-mesa-dev" "libxml2-utils" "xsltproc" "unzip" "fontconfig")
elif dpkg --compare-versions "$UBUNTU_REL_VER" "ge" "16.04"; then
    # Ubuntu 16.04 up to 22.04
    APT_PACKAGES+=("gcc-multilib" "g++-multilib" "libc6-dev-i386" "lib32ncurses5-dev" "x11proto-core-dev" "libx11-dev" "lib32z-dev" "ccache" "libgl1-mesa-dev" "libxml2-utils" "xsltproc" "unzip" "libnss-sss:i386")
elif dpkg --compare-versions "$UBUNTU_REL_VER" "ge" "12.04"; then
    # Ubuntu 12.04 up to 14.04
    APT_PACKAGES+=("libc6-dev" "libncurses5-dev:i386" "x11proto-core-dev" "libx11-dev:i386" "libreadline6-dev:i386" "libgl1-mesa-glx:i386" "libgl1-mesa-dev" "g++-multilib" "mingw32" "python-markdown" "libxml2-utils" "xsltproc" "zlib1g-dev:i386")
fi

# Webmin dependencies
echo + Webmin dependencies
APT_PACKAGES+=("apt-show-versions" "libauthen-pam-perl")

# Teamviewer dependencies
echo + Teamviewer dependencies
APT_PACKAGES+=("lib32asound2" "lib32z1" "ia32-libs")

# Tweak Ubuntu dedendencies
echo + Tweak Ubuntu dependencies
APT_PACKAGES+=("python-xdg" "python-aptdaemon" "python-aptdaemon.gtk3widgets" "python-defer" "python-compizconfig" "gir1.2-gconf-2.0" "gir1.2-webkit-3.0")

# Kodi dependency
echo + Kodi dependencies
APT_PACKAGES+=("software-properties-common")

# GNOME and extra tools
echo + GNOME extra tools dependencies
APT_PACKAGES+=("ubuntu-restricted-extras")

# Third party PPA
echo + Third party packages
APT_PACKAGES+=("timeshift")

echo
echo Making DAI list...
# Packages to download and install (DAI)
# Format: "URL SHA256SUM" (Use "SKIP" to bypass verification)
DAI_PACKAGES=(
    "https://excellmedia.dl.sourceforge.net/project/webadmin/webmin/2.630/newkey-webmin_2.630_all.deb SKIP"
    "https://download.teamviewer.com/download/linux/teamviewer_amd64.deb SKIP"
    # "http://archive.getdeb.net/ubuntu/pool/apps/u/ubuntu-tweak/ubuntu-tweak_0.8.7-1~getdeb2~xenial_all.deb"
)

echo
echo Making DO list...
# Packages to download only (DO)
# Format: "URL SHA256SUM" (Use "SKIP" to bypass verification)
DO_PACKAGES=(
    "https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.54/bin/apache-tomcat-10.1.54.zip SKIP"
    "https://updates.jenkins.io/download/war/2.562/jenkins.war SKIP"
)

echo
echo Making PPA list...
# Add all PPAs here
APT_PPAS=(
    "ppa:tualatrix/ppa"
    "ppa:team-xbmc/ppa"
    "ppa:apt-fast/stable"
    "ppa:linrunner/tlp"
    "ppa:teejee2008/ppa"
    "universe"
)

function runPerPostInstall {
    case "$1" in
        squid-deb-proxy)
            # Check if squid is running.
            # TODO: Make sure it is squid deb proxy
            pidof squid3 > /dev/null
            if [ $? -ne 0 ] ; then
                echo
                echo Starting squid deb proxy for caching...
                #/etc/init.d/squid-deb-proxy start
            fi
            ;;
        ttf-mscorefonts-installer)
            echo "Check if there are errors in MS Font install..."
            dpkg --configure -a
            if [ $? -eq 0 ] ; then
                echo "No issues. Continue..."
            else
                dpkg -P "$1"
            fi
            ;;
    esac
}

function runPostInstall {
    echo
    echo Running post install steps...

    # Configuration specific to AOSP builds
    echo
    echo Update java links...
    $CMD_SIMULATION update-alternatives --auto java >> $LOGGER 2>&1
    $CMD_SIMULATION update-alternatives --auto javac >> $LOGGER 2>&1

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
    for DAI_ENTRY in "${DAI_PACKAGES[@]}"; do
        read -r DAI_PACKAGE DAI_CHECKSUM <<< "$DAI_ENTRY"
        PACKAGE_NAME=`basename "$DAI_PACKAGE"`
        if [ -e "$DOWNLOAD_PATH/$PACKAGE_NAME" ] ; then
            echo
            printf "Using existing package $PACKAGE_NAME... "
            WGET_STATUS=0
            DUR_STR="0s"
        else
            echo
            printf "%-40s" "Download $PACKAGE_NAME... "
            PKG_START=$SECONDS
            $CMD_SIMULATION wget -N -P "$DOWNLOAD_PATH" "$DAI_PACKAGE" >> $LOGGER 2>&1
            WGET_STATUS=$?
            PKG_DUR=$((SECONDS - PKG_START))
            if [ $PKG_DUR -ge 60 ]; then DUR_STR="$((PKG_DUR / 60))m $((PKG_DUR % 60))s"; else DUR_STR="${PKG_DUR}s"; fi
        fi

        if [ $WGET_STATUS -eq 0 ] ; then
            printf "${GREEN}Done ($DUR_STR)${NORMAL}\n"

            # Checksum Verification
            if [ -n "$DAI_CHECKSUM" ] && [ "$DAI_CHECKSUM" != "SKIP" ]; then
                echo
                printf "%-40s" "Verify checksum for $PACKAGE_NAME... "
                if $CMD_SIMULATION echo "$DAI_CHECKSUM  $DOWNLOAD_PATH/$PACKAGE_NAME" | $CMD_SIMULATION sha256sum -c --quiet - >> $LOGGER 2>&1; then
                     printf "${GREEN}OK\n${NORMAL}"
                else
                     printf "${RED}Failed!\n${NORMAL}"
                     echo "Checksum mismatch for $PACKAGE_NAME! Skipping installation." >> $LOGGER
                     continue
                fi
            fi

            echo
            printf "%-40s" "Install $DAI_PACKAGE... "
            PKG_START=$SECONDS
            $CMD_SIMULATION dpkg -i "$DOWNLOAD_PATH/$PACKAGE_NAME" >> $LOGGER 2>&1
            DPKG_STATUS=$?
            PKG_DUR=$((SECONDS - PKG_START))
            if [ $PKG_DUR -ge 60 ]; then DUR_STR="$((PKG_DUR / 60))m $((PKG_DUR % 60))s"; else DUR_STR="${PKG_DUR}s"; fi
            if [ $DPKG_STATUS -eq 0 ] ; then
                printf "${GREEN}Done ($DUR_STR)${NORMAL}\n"
            else
                printf "${RED}Failed! ($DUR_STR)${NORMAL}\n"
            fi
        else
            printf "${RED}Failed! ($DUR_STR)${NORMAL}\n"
        fi
    done
}

function processDOPackages {
    echo
    echo "Process DO packages..."
    # Process DO packages
    for DO_ENTRY in "${DO_PACKAGES[@]}"; do
        read -r DO_PACKAGE DO_CHECKSUM <<< "$DO_ENTRY"
        PACKAGE_NAME=`basename "$DO_PACKAGE"`
        if [ -e "$DOWNLOAD_PATH/$PACKAGE_NAME" ] ; then
            echo
            printf "Package already downloaded: $PACKAGE_NAME..."
            WGET_STATUS=0
        else
            echo
            printf "%-40s" "Download $PACKAGE_NAME... "
            PKG_START=$SECONDS

            # Verify URL reachability before downloading
            if ! $CMD_SIMULATION wget -q --spider --timeout=5 "$DO_PACKAGE" >> $LOGGER 2>&1; then
                PKG_DUR=$((SECONDS - PKG_START))
                if [ $PKG_DUR -ge 60 ]; then DUR_STR="$((PKG_DUR / 60))m $((PKG_DUR % 60))s"; else DUR_STR="${PKG_DUR}s"; fi
                printf "${RED}Unreachable! ($DUR_STR)${NORMAL}\n"
                echo "URL $DO_PACKAGE is unreachable." >> $LOGGER
                REPORT_FAILED_DO+=("$PACKAGE_NAME (unreachable)")
                continue
            fi

            $CMD_SIMULATION wget -N -P "$DOWNLOAD_PATH" "$DO_PACKAGE" >> $LOGGER 2>&1
            WGET_STATUS=$?
            PKG_DUR=$((SECONDS - PKG_START))
            if [ $PKG_DUR -ge 60 ]; then DUR_STR="$((PKG_DUR / 60))m $((PKG_DUR % 60))s"; else DUR_STR="${PKG_DUR}s"; fi
            if [ $WGET_STATUS -eq 0 ]; then
                printf "${GREEN}Done ($DUR_STR)${NORMAL}\n"
            else
                printf "${RED}Failed! ($DUR_STR)${NORMAL}\n"
            fi
        fi

        if [ $WGET_STATUS -eq 0 ] && [ -n "$DO_CHECKSUM" ] && [ "$DO_CHECKSUM" != "SKIP" ]; then
            echo
            printf "%-40s" "Verify checksum for $PACKAGE_NAME... "
            if $CMD_SIMULATION echo "$DO_CHECKSUM  $DOWNLOAD_PATH/$PACKAGE_NAME" | $CMD_SIMULATION sha256sum -c --quiet - >> $LOGGER 2>&1; then
                printf "${GREEN}OK\n${NORMAL}"
            else
                printf "${RED}Failed!\n${NORMAL}"
                echo "Checksum mismatch for $PACKAGE_NAME! Removing invalid file." >> $LOGGER
                $CMD_SIMULATION rm -f "$DOWNLOAD_PATH/$PACKAGE_NAME"
            fi
        fi
    done
}

function updatePPAs {
    echo
    echo "Updating PPAs..."
    for APT_PPA in "${APT_PPAS[@]}"; do
        echo
        printf "%-40s" "Adding PPA: $APT_PPA... "

        # Check if PPA is already added
        PPA_EXISTS=1
        if [[ "$APT_PPA" == ppa:* ]]; then
            PPA_REPO="${APT_PPA#ppa:}"

            # Verify reachability/compatibility before adding
            PPA_URL="https://ppa.launchpadcontent.net/$PPA_REPO/ubuntu/dists/$UBUNTU_CODENAME/Release"
            if ! $CMD_SIMULATION wget -q --spider --timeout=5 "$PPA_URL" >> $LOGGER 2>&1; then
                printf "${RED}Unreachable!${NORMAL}\n"
                echo "PPA $APT_PPA is unreachable or unsupported on Ubuntu $UBUNTU_CODENAME." >> $LOGGER
                REPORT_FAILED_PPA+=("$APT_PPA (unreachable)")
                continue
            fi

            grep -qrE "ppa\.launchpad(content)?\.net/$PPA_REPO" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null
            PPA_EXISTS=$?
        else
            grep -qrE "^deb .*\s$APT_PPA(\s|$)" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null
            PPA_EXISTS=$?
        fi

        if [ $PPA_EXISTS -eq 0 ]; then
            printf "${GREEN}Already added${NORMAL}\n"
            REPORT_SUCCESS_PPA=$((REPORT_SUCCESS_PPA + 1))
            continue
        fi

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
    for APT_PACKAGE in "${APT_PACKAGES[@]}"; do
        echo
        printf "%-40s" "Install $APT_PACKAGE... "
        PKG_START=$SECONDS
        apt-get $APT_OPT_FLAGS install $APT_PACKAGE >> $LOGGER 2>&1
        APT_STATUS=$?
        PKG_DUR=$((SECONDS - PKG_START))
        if [ $PKG_DUR -ge 60 ]; then DUR_STR="$((PKG_DUR / 60))m $((PKG_DUR % 60))s"; else DUR_STR="${PKG_DUR}s"; fi
        if [ $APT_STATUS -eq 0 ] ; then
            printf "${GREEN}Done ($DUR_STR)${NORMAL}\n"
            $CMD_SIMULATION runPerPostInstall $APT_PACKAGE
            REPORT_SUCCESS_APT=$((REPORT_SUCCESS_APT + 1))
        else
            printf "${RED}Failed! ($DUR_STR)${NORMAL}\n"
            REPORT_FAILED_APT+=("$APT_PACKAGE")
        fi
    done
}

function generateReport {
    echo
    echo "==============================================================================="
    echo "                               INSTALLATION REPORT                             "
    echo "==============================================================================="
    echo
    printf "%-30s : %d\n" "APT Packages Installed" "$REPORT_SUCCESS_APT"
    printf "%-30s : %d\n" "DAI Packages Installed" "$REPORT_SUCCESS_DAI"
    printf "%-30s : %d\n" "DO Packages Downloaded" "$REPORT_SUCCESS_DO"
    printf "%-30s : %d\n" "PPAs Added" "$REPORT_SUCCESS_PPA"
    
    if [ ${#REPORT_FAILED_APT[@]} -gt 0 ] || [ ${#REPORT_FAILED_DAI[@]} -gt 0 ] || [ ${#REPORT_FAILED_DO[@]} -gt 0 ] || [ ${#REPORT_FAILED_PPA[@]} -gt 0 ]; then
        echo
        echo "-------------------------------------------------------------------------------"
        printf "${RED}FAILURES DETECTED${NORMAL}\n"
        echo "-------------------------------------------------------------------------------"
        
        if [ ${#REPORT_FAILED_PPA[@]} -gt 0 ]; then
            echo "Failed PPAs:"
            for fail in "${REPORT_FAILED_PPA[@]}"; do
                echo "  - $fail"
            done
            echo
        fi

        if [ ${#REPORT_FAILED_APT[@]} -gt 0 ]; then
            echo "Failed APT Packages:"
            for fail in "${REPORT_FAILED_APT[@]}"; do
                echo "  - $fail"
            done
            echo
        fi

        if [ ${#REPORT_FAILED_DAI[@]} -gt 0 ]; then
            echo "Failed DAI Packages (Download And Install):"
            for fail in "${REPORT_FAILED_DAI[@]}"; do
                echo "  - $fail"
            done
            echo
        fi

        if [ ${#REPORT_FAILED_DO[@]} -gt 0 ]; then
            echo "Failed DO Packages (Download Only):"
            for fail in "${REPORT_FAILED_DO[@]}"; do
                echo "  - $fail"
            done
            echo
        fi
    else
        echo
        echo "-------------------------------------------------------------------------------"
        printf "${GREEN}ALL OPERATIONS COMPLETED SUCCESSFULLY!${NORMAL}\n"
        echo "-------------------------------------------------------------------------------"
    fi
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

if [ $INTERACTIVE -eq 0 ]; then
    # Preseed answers for interactive prompts
    $CMD_SIMULATION echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | $CMD_SIMULATION sudo debconf-set-selections >> $LOGGER 2>&1
    $CMD_SIMULATION echo wireshark-common wireshark-common/install-setuid boolean true | $CMD_SIMULATION sudo debconf-set-selections >> $LOGGER 2>&1
fi

MAX_RETRIES=3
RETRY_COUNT=0
FIX_SUCCESS=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    $CMD_SIMULATION dpkg --configure -a --force-configure-any >> $LOGGER 2>&1
    DPKG_STATUS=$?
    $CMD_SIMULATION apt-get --fix-broken -y install >> $LOGGER 2>&1
    APT_STATUS=$?

    if [ $DPKG_STATUS -eq 0 ] && [ $APT_STATUS -eq 0 ]; then
        FIX_SUCCESS=1
        break
    fi

    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "Retrying to fix broken installations (Attempt $RETRY_COUNT/$MAX_RETRIES)..."
done

if [ $FIX_SUCCESS -eq 0 ]; then
    printf "${RED}Warning: Could not completely fix broken installations after $MAX_RETRIES attempts.${NORMAL}\n"
fi

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

# Generate final installation report
{
    generateReport

    EXEC_MINS=$((SECONDS / 60))
    EXEC_SECS=$((SECONDS % 60))
    echo "-------------------------------------------------------------------------------"
    printf "%-30s : %dm %ds\n" "Total Execution Time" "$EXEC_MINS" "$EXEC_SECS"
    echo "==============================================================================="
} | tee -a "$LOGGER"

echo
echo Done... See you after next install!
echo

END_TIME=`date` >> $LOGGER
echo "IMU completed at: $END_TIME" >> $LOGGER 2>&1

if [ $SHUTDOWN -eq 1 ] ; then
    echo System will shutdown in $SHUTDOWN_DELAY minutes.
    echo You may abort the shutdown using the command \'shutdown -c\'
    echo
    $CMD_SIMULATION shutdown -h +$SHUTDOWN_DELAY &
fi
