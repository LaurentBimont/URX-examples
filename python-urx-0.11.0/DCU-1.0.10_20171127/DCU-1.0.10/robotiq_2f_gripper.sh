#!/bin/sh
### BEGIN INIT INFO
# Provides:          robotiq_2f_gripper
# Required-Start:    mountdevsubfs $network $remote_fs
# Required-Stop:     mountdevsubfs $network $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts the Robotiq 2f Gripper Driver 
# Description:       The driver needs the ftdi_sio driver to open
#                    the device ttyUSBx
### END INIT INFO

# Author: Pierre-Olivier Proulx <poproulx@robotiq.com>

DRIVER_NAME=robotiq_2f_gripper_driver
DRIVER_DAEMON_DIR=/root/robotiq_2f_gripper_driver
DRIVER_DAEMON=$DRIVER_DAEMON_DIR/$DRIVER_NAME
DRIVER_PIDFILE=/var/run/$DRIVER_NAME.pid

GUI_NAME=gripper_client_gui_start.sh
GUI_DAEMON_DIR=/root/gripper_client_gui
GUI_DAEMON=$GUI_DAEMON_DIR/$GUI_NAME
GUI_PIDFILE=/var/run/gripper_client_gui.pid
GUI_EXEC=/usr/bin/java

case "$1" in
  start)
	start-stop-daemon --start --pidfile $DRIVER_PIDFILE -m -d $DRIVER_DAEMON_DIR --exec $DRIVER_DAEMON -N 18 -b
	start-stop-daemon --start -b --exec $GUI_DAEMON -- "-p" "$GUI_PIDFILE"
	echo $GUI_DAEMON_FILE
	;;
  restart|reload|force-reload)
	echo "Error: argument '$1' not supported" >&2
	exit 3
	;;
  stop)
	start-stop-daemon --stop --pidfile $DRIVER_PIDFILE
	start-stop-daemon --stop --pidfile $GUI_PIDFILE > /dev/null
	;;
  *)
	echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload}" >&2
	exit 3
	;;
esac
