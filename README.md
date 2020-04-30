
init_my_ubuntu (IMU)
====================

A post install script to install useful software and configure your system
after a fresh Ubuntu installation.

IMU goes through the following steps:
1. Fix broken installations
2. DAI package (Download And Install, These are deb packages)
3. Update PPAs (Required for a few packages)
4. Install packages (Using packages list)
5. DO packages (Download Only, Download packages for manual installation)
6. Post install custom scripts (These are used to configure specific needs)
7. Auto shutdown if enabled

Steps to run:
=============
1. Go root
2. ./init_my_ubuntu

OR

Add it to your install post-build (never tested)

Simulation Mode
===============

IMU supports simulation mode, this can be used if you do not want to make
any changes to your system but see what IMU will install and configure.

To enable Simulation mode, set SIMULATION=1 within the script and run.

Logs
====

To view installation logs:
1. Update LOGGING=1 inside script and run
2. tail -f imu.log in another shell
