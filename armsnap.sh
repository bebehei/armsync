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

# provide default values
SNAP_TIME="$(date +%Y/%m/%d/%H)"

[ -z $VARS_FILE ] && die VARS_FILE not defined
[ -r $VARS_FILE ] && die VARS_FILE $VARS_FILE not readable

. $VARS_FILE

while [ -f $SYNC_LOCK ]; do
	sleep 1;
done

mkdir -p $SNAP_FILES/$SNAP_TIME

cp --recursive --link $SYNC_FILES $SNAP_FILES/$SNAP_TIME
