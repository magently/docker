#!/bin/bash
set -e

PREFIX="$1"

##
# Reverts stored symlinks
##
function revert_app_symlinks()
{
	if [ -h "$SYNC_DEST/$1" ] && [[ "$(readlink -m "$SYNC_DEST/$1")" == "$SYNC_SRC"* ]]; then
		rm "$SYNC_DEST/$1"
		[ ! -e "$SYNC_STORAGE/$1" ] || mv "$SYNC_STORAGE/$1" "$SYNC_DEST/$1"
		[ ! -e "$SYNC_STORAGE/$1.fake" ] || rm "$SYNC_STORAGE/$1.fake"
	elif [ -d "$SYNC_STORAGE/$1" ]; then
		for FILE in $(ls -1a "$SYNC_STORAGE/$1" | grep -vP "^\.{1,2}$"); do
			revert_app_symlinks "$1/${FILE%.fake}/"
		done
	fi
}

# Trigger revert
revert_app_symlinks "${2%/}"
