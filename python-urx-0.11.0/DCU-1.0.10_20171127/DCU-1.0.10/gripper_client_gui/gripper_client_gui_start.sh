#!/bin/bash

# 2 arguments?
if [ $# -ne 2 ]; then
	echo "need pid file. -p /file/name"
	exit 0
fi

# if arg 1 is -p, assume arg 2 is the pid file
if [ $1 == "-p" ]; then
	PIDFILE=$2
else
	exit 0
fi

# wait until port 29999 is open. (polyscope opens the dashboard)
while true; do
	result=$(netstat -nlt | grep -c 29999)
	if [ $result -ne 0 ]; then
		break
	fi
    sleep 1
done

# wait for polyscope to be fully loaded. if not, the 
# gripper gui will be under polyscode and thus invisible.
sleep 15s

# launch the gripper gui
export DISPLAY=0:0
start-stop-daemon --start --pidfile $PIDFILE -m -b --exec /usr/bin/java -- "-jar" "/root/gripper_client_gui/gripper_client_gui.jar" "127.0.0.1" "252x0"
