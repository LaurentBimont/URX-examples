#!/bin/sh
# 
# file   urmagic_robotiq_gripper.sh
# author Jonathan Savoie <jonathan.savoie@robotiq.com>
# maintainer Nicolas Lauzier <nicolas@robotiq.com">
# maintainer Pierre-Olivier Proulx <poproulx@robotiq.com">
#  
# Script to install the driver and also the macros
# 

DCU_VERSION="1.0.10"
MOUNTPOINT="$1"
UR_MAGIC_LOCATION="`dirname "${BASH_SOURCE[0]}"`"

LOGGER="/usr/bin/logger"
TAG="-t '$(basename $0)'"

FTDI_CONF_FILE='/etc/modprobe.d/ftdi_sio.conf'
FTDI_CONF_OPTION='options ftdi_sio product=0x6015 vendor=0x0403'
FTDI_CONF_ALIAS='alias usb:v0403p6015d*dc*dsc*dp*ic*isc*ip* ftdi_sio'

function get_controller_version () {
	regex="([0-9]+)\.([0-9]+)"
	match="`echo "polyscopeVersion" | netcat 127.0.0.1 29999 -q1`"
	ur_version="CB2"

	[[ $match =~ $regex ]]
	
	if [ "${BASH_REMATCH[1]}" == "3" ]; then
		ur_version="CB3"
	elif [ "${BASH_REMATCH[1]}" == "1" ]; then
		ur_version="CB2"
	else
		ur_version="CB2"
	fi
}

function is_CB2 () {
	get_controller_version
	if [ "${ur_version}" == "CB2" ]; then
		return 0
	else
		return 1
	fi
}

function is_CB3 () {
	get_controller_version
	if [ "${ur_version}" == "CB3" ]; then
		return 0
	else
		return 1
	fi
}

function is_files_present () {
	if [ ! -d $1/driver ]; then
		return 1
	fi

	if [ ! -d $1/ftdi_driver ]; then
		return 1
	fi

	if [ ! -d $1/gripper_client_gui ]; then
		return 1
	fi

	if [ ! -d $1/robotiq_2f_gripper_programs_CB2 ]; then
		return 1
	fi

	if [ ! -d $1/robotiq_2f_gripper_programs_CB3 ]; then
		return 1
	fi

	if [ ! -f $1/robotiq_2f_gripper.sh ]; then
		return 1
	fi

	if [ ! -f $1/uninstall.sh ]; then
		return 1
	fi

	return 0
}

PROGRAMS_DIR_DEST="robotiq_2f_gripper_programs"
if  is_CB2; then
	PROGRAMS_DIR_SRC="${PROGRAMS_DIR_DEST}_CB2"
	echo "Controller : CB2"
elif is_CB3; then
	PROGRAMS_DIR_SRC="${PROGRAMS_DIR_DEST}_CB3"
	echo "Controller : CB3"
else
	echo "Invalid controller"
	exit 1
fi

if [ "$1" = "" ] ; then
    $LOGGER -p user.info $TAG "$0: no mountpoint supplied, exiting."
    exit 1 ; fi

# Warn user not to remove USB key
echo "! USB !" | DISPLAY=:0 aosd_cat -R red -x 230 -y -210 -n "Arial Black 80"
echo "Installing Robotiq 2F Gripper Driver DCU-${DCU_VERSION}" | DISPLAY=:0 aosd_cat -R blue -x 230 -y -310 -n "Arial Black 30"

#check if files are present
if is_files_present ${UR_MAGIC_LOCATION}; then
	echo "files presents"
else
	echo "Installation files missing. Unzip software package properly." | DISPLAY=:0 aosd_cat -R red -x 230 -y -210 -n "Arial Black 80"

	exit 1
fi

echo "Installing DCU-${DCU_VERSION}"

DEST=("/programs")
	
if [ -d ~/robotiq_2f_gripper_driver ]; then
echo "The driver is already installed. Overwriting." | DISPLAY=:0 aosd_cat -R blue -x 230 -y -310 -n "Arial Black 30"
fi

# Stopping and removing the init.d scripts
/etc/init.d/robotiq_2f_gripper.sh stop
rm -f /etc/init.d/robotiq_2f_gripper.sh
update-rc.d robotiq_2f_gripper.sh remove

if [ -f $FTDI_CONF_FILE ]; then
        MSG="FTDI conf file already exists."
        echo $MSG
        echo $MSG | DISPLAY=:0 aosd_cat -R blue -x 230 -y -370 -n "Arial Black 25" &
else
        MSG="FTDI conf file does not exist. Creating it."
        echo $MSG
        echo $MSG | DISPLAY=:0 aosd_cat -R blue -x 230 -y -370 -n "Arial Black 25" &

        echo "# This file allows the ftdi_sio driver to use FT X series." > $FTDI_CONF_FILE
        echo $FTDI_CONF_OPTION >> $FTDI_CONF_FILE
        echo $FTDI_CONF_ALIAS >> $FTDI_CONF_FILE
fi

if [ -f "/lib/modules/`uname -r`/kernel/drivers/usb/serial/ftdi_sio.ko" ]; then 
    echo "FTDI module already loaded."
    echo "FTDI module already loaded." | DISPLAY=:0 aosd_cat -R blue -x 230 -y -310 -n "Arial Black 25" &

    # if a symbolic link exists in this directory, it has been 
    # made by an outdated gripper driver. Remove those links
    # since they prevent ftdi module to be loaded.
    if [ -h "/lib/modules/`uname -r`/ftdi_sio.ko" ]; then
        rm /lib/modules/`uname -r`/ftdi_sio.ko
    fi

    if [ -h "/lib/modules/`uname -r`/usbserial.ko" ]; then
        rm /lib/modules/`uname -r`/usbserial.ko
    fi

    depmod -a
    modprobe ftdi_sio product=0x6015 vendor=0x0403
else
    # Copy the ftdi modules on the system
    cp -f $UR_MAGIC_LOCATION/ftdi_driver/ftdi_sio.ko /root/
    cp -f $UR_MAGIC_LOCATION/ftdi_driver/usbserial.ko /root/
    ln -sf /root/ftdi_sio.ko /lib/modules/$(uname -r)/
    ln -sf /root/usbserial.ko /lib/modules/$(uname -r)/
    
    # Resolve the dependancies and load the modules
    echo "Loading module ftdi_sio" 
    echo "Loading module ftdi_sio" | DISPLAY=:0 aosd_cat -R blue -x 230 -y -310 -n "Arial Black 25" &
    depmod -a
    modprobe ftdi_sio product=0x6015 vendor=0x0403

fi

$LOGGER -p user.info $TAG "$0: copying files from $UR_MAGIC_LOCATION to $DEST..."

# Copy the driver
echo "Copying the driver" | DISPLAY=:0 aosd_cat -R blue -x 230 -y -260 -n "Arial Black 25" &
mkdir -p ~/robotiq_2f_gripper_driver
cp -rf $UR_MAGIC_LOCATION/driver/robotiq_2f_gripper_driver ~/robotiq_2f_gripper_driver/
chmod +x ~/robotiq_2f_gripper_driver/robotiq_2f_gripper_driver
cp -rf $UR_MAGIC_LOCATION/driver/fuser ~/robotiq_2f_gripper_driver/
chmod +x ~/robotiq_2f_gripper_driver/fuser
cp -rf $UR_MAGIC_LOCATION/driver/lib ~/robotiq_2f_gripper_driver/
ln -sf ~/robotiq_2f_gripper_driver/lib/libmodbus.so.5.0.5 ~/robotiq_2f_gripper_driver/lib/libmodbus.so.5

# Copy the gui
cp -rf $UR_MAGIC_LOCATION/gripper_client_gui ~/
chmod +x ~/gripper_client_gui/gripper_client_gui_start.sh

# Copy the scripts
echo "Copying the scripts" | DISPLAY=:0 aosd_cat -R blue -x 230 -y -220 -n "Arial Black 25" &
mkdir -p /programs/$PROGRAMS_DIR_DEST
cp -rf $UR_MAGIC_LOCATION/$PROGRAMS_DIR_SRC/* /programs/$PROGRAMS_DIR_DEST/
$LOGGER -p user.info $TAG "$0: ...copy done."

# Loading the init.d script
echo "Loading the init.d script" | DISPLAY=:0 aosd_cat -R blue -x 230 -y -180 -n "Arial Black 25" &
cp -rf $UR_MAGIC_LOCATION/robotiq_2f_gripper.sh /etc/init.d/
chmod a+x /etc/init.d/robotiq_2f_gripper.sh
export PATH=${PATH}:/sbin:/usr/sbin
update-rc.d robotiq_2f_gripper.sh defaults
$LOGGER -p user.info $TAG "$0: Robotiq 2F Gripper init.d script loaded"

echo "Starting the driver" | DISPLAY=:0 aosd_cat -R blue -x 230 -y -130 -n "Arial Black 25"
/etc/init.d/./robotiq_2f_gripper.sh start
$LOGGER -p user.info $TAG "$0: Robotiq 2f Gripper Driver started"

# Notify user it is ok to remove USB key
echo "<- USB" | DISPLAY=:0 aosd_cat -x 200 -y -210 -n "Arial Black 80"

exit 0;
