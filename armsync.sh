#!/bin/bash
#
# The script to sync a local mirror of the Arch Linux repositories and ISOs
#
# Copyright (C) 2007 Woody Gilk <woody@archlinux.org>
# Modifications by Dale Blount <dale@archlinux.org>
# and Roman Kyrylych <roman@archlinux.org>
# Comments translated to German by Dirk Sohler <dirk@0x7be.de>
# Licensed under the GNU GPL (version 2)
# Rewrite by Benedikt Heine <bebe@bebehei.de>

function die(){
	echo $@ >&2
	exit 1
}

function info(){
	ret=$@
	[ $VERBOSITY -ge $1 ] && echo ${ret[@]:1}
}

function log(){
	echo $@ >> "$SYNC_LOGS/$SYNC_LOGFILE"
}

# provide default values
SYNC_OPTIONS=('-rptvL' '--delete-after' '--delay-updates')
LOG_FILE="pkgsync_$(date +%Y%m%d-%H).log"

[ -z $VARS_FILE ] && die VARS_FILE not defined
[ -r $VARS_FILE ] && die VARS_FILE not readable

. $VARS_FILE

# check variables
[ -z $SYNC_HOME ] && die "SYNC_HOME is not initialized"
[ -z $SYNC_LOGS ] && die "SYNC_LOGS is not initialized"
[ -z $SYNC_FILES ] && die "SYNC_FILES is not initialized"
[ -z $SYNC_SERVER ] && die "SYNC_SERVER is not initialized"

[ ! -d $SYNC_HOME ] && die "$SYNC_HOME does not exist"
[ ! -d $SYNC_LOGS ] && die "$SYNC_LOGS does not exist"
[ ! -d $SYNC_FILES ] && die "$SYNC_FILES does not exist"

# Process the sources-array
SOURCES=()
for repo in ${SYNC_REPO[@]}; do
	repo=$(echo $repo | tr [:upper:] [:lower:])
	SOURCES+=("$SYNC_SERVER/$repo")
done

# add as default just the repo-server if no SYNC_REPO is empty
if [[ ${#SOURCES[@]} -eq 0 ]]; then
	SOURCES=($SYNC_SERVER)
fi

# lock the ARM
[ -f $SYNC_LOCK ] && die "Could not lock ARM: $SYNC_LOCK exists"
touch "$SYNC_LOCK"

# start logfile and timestamp it
touch "$SYNC_LOGS/$SYNC_LOGFILE"
log "============================================="
log ">> Starting sync on $(date --rfc-3339=seconds)"
log ">> ---"

for src in ${SOURCES[@]}; do
		info 1 Starting Sync for $src

    log ">> Syncing $src to $SYNC_FILES/$repo"

		# sync the repository
    rsync ${SYNC_OPTIONS[@]} $src "$SYNC_FILES" >> "$SYNC_LOGS/$SYNC_LOGFILE"

		# wait after every repo to finish rsync-connections
		# avoids failing rsync of too much connections
		sleep 5
done

# finish logfile with timestamp
log ">> ---"
log ">> Finished sync on $(date --rfc-3339=seconds)"
log "============================================="
log

# unlock the ARM
rm -f $SYNC_LOCK
exit 0
