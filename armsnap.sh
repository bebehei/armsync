#!/bin/bash

function die(){
	echo $@ >&2
	exit 1
}

function info(){
	ret=$@
	[ $VERBOSITY -ge $1 ] && echo ${ret[@]:1}
}

function log(){
	echo $@ >> "$SYNC_LOGS/$LOG_FILE"
}

. $VARS_FILE

if [ $SNAP_WAIT_SYNC -eq 1 ]; then
	while [ -f $SYNC_LOCK ]; do
		sleep 1;
	done
fi

mkdir -p $SNAP_FILES/$SNAP_TIME

cp --recursive --link $SYNC_FILES $SNAP_FILES/$SNAP_TIME
