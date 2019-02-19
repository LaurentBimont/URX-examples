#!/bin/sh
# 
# file   urmagic_uninstall.sh
# author Pierre-Olivier Proulx <poproulx@robotiq.com">
#  
# Uninstall script for Robotiq 2F Gripper Driver
#

LOGGER="/usr/bin/logger"
TAG="-t '$(basename $0)'"

if [ "$1" = "" ] ; then
    $LOGGER -p user.info $TAG "$0: no mountpoint supplied, exiting."
    exit 1 ; fi

# Warn user not to remove USB key
echo "! USB !" | DISPLAY=:0 aosd_cat -R red -x 230 -y -210 -n "Arial Black 80"
echo "Uninstalling Robotiq 2F Gripper Program" | DISPLAY=:0 aosd_cat -R blue -x 230 -y -310 -n "Arial Black 30"

# Stopping and removing the init.d scripts
/etc/init.d/robotiq_2f_gripper.sh stop
rm -f /etc/init.d/robotiq_2f_gripper.sh
update-rc.d robotiq_2f_gripper.sh remove
rm -rf ~/robotiq_2f_gripper_driver
rm -rf ~/gripper_client_gui

# Notify user it is ok to remove USB key
echo "<- USB" | DISPLAY=:0 aosd_cat -x 200 -y -210 -n "Arial Black 80"

exit 0;
