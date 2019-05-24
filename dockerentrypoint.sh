#!/bin/sh

set -e

BASE_DIR=$(cd `dirname $0` && pwd)
DGD_SRC="$BASE_DIR/dgd/src"
MUD_SRC="$BASE_DIR/src"
EXT_DIR="$BASE_DIR/lpc-ext"
DGD_PIDFILE="$BASE_DIR/state/dgd.pid"
DGD_STOPPED="n"
STOP_DGD="n"

function log() {
	local TOPIC="$1"
	shift 1
	local MESSAGE="$@"
	
	echo "[$TOPIC] $MESSAGE"
}

function get_snapshots() {
	local SNAPSHOTS=""

	if [ -f "$BASE_DIR/state/snapshot" ]; then
		SNAPSHOTS="$BASE_DIR/state/snapshot"
	fi

	if [ -f "$BASE_DIR/state/snapshot.old" ]; then
		SNAPSHOTS="$SNAPSHOTS $BASE_DIR/state/snapshot.old"
	fi

	echo "$SNAPSHOTS"
}

function dgd_running() {
	if [ ! -f "$DGD_PIDFILE" ]; then
		return 1
	fi

	local PID=`cat $DGD_PIDFILE`
	if ! kill -0 "$PID" 2>/dev/null; then
		rm "$DGD_PIDFILE"
		return 1
	fi
}

function start_dgd() {
	if dgd_running; then
		return 1
	fi
	
	local DGD_PID
	local SNAPSHOT_FILES="$(get_snapshots)"
	
	dgd "$BASE_DIR/cloud.dgd" $SNAPSHOT_FILES 2>&1 &
	sleep 1
	DGD_PID=`pidof dgd`
	
	if [ -z "$DGD_PID" ]; then
		log main "Error when starting dgd."
		return 1
	fi
	
	log main "Started DGD with snapshots \"$SNAPSHOT_FILES\" and PID $DGD_PID."
	echo "$DGD_PID" > "$DGD_PIDFILE"
}

function stop_dgd() {
	if ! dgd_running; then
		return 1
	fi

	local DGD_PID=`cat "$DGD_PIDFILE"`
	kill -15 $DGD_PID
	sleep 5
	if dgd_running; then
		log main "Error trying to stop DGD."
		return 1
	fi
	
	log "main" "DGD has been stopped."
	DGD_STOPPED="y"
}

function end_loop() {
	log main "Stopping DGD..."
	STOP_DGD="y"
}

trap end_loop SIGINT SIGTERM

FIRST_TIME="y"

while [ "x$STOP_DGD" = "xn" ]; do
	if ! dgd_running; then
		# check if we have to restart dgd
		if [ -f "$BASE_DIR/mud/kernel/data/.reboot" ]; then
			start_dgd
		else
			if [ "x$FIRST_TIME" = "xy" ]; then
				FIRST_TIME="n"
				start_dgd
			else
				STOP_DGD="y"
			fi
		fi
	fi
	
	sleep 1
done

while dgd_running; do
	stop_dgd
done
