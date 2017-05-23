#!/bin/bash
set -e

export SYNC_SRC="$PACKAGES_PATH"
export SYNC_DEST="$MAGENTO_PATH"
export SYNC_STORAGE="/tmp/sync"

# Create sync storage
[ -e "$SYNC_STORAGE" ] || gosu "www-data" mkdir "$SYNC_STORAGE"

for path in $(find "$SYNC_SRC" -mindepth 2 -maxdepth 2 -type d); do
    PREFIX="${path#$SYNC_SRC/}"
    gosu "www-data" /opt/docker/sync/revert-app-symlinks.sh "$PREFIX"
    gosu "www-data" /opt/docker/sync/create-app-symlinks.sh "$PREFIX"
done
