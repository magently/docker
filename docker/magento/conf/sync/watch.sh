#!/bin/bash
set -e

export SYNC_SRC="$PACKAGES_PATH"
export SYNC_DEST="$MAGENTO_PATH"
export SYNC_STORAGE="/tmp/sync"

function watch
{
    echo "Watching packages in $SYNC_SRC ..."

    # Watch /app changes
    inotifywait -mr -e modify -e attrib -e move -e create -e delete -e delete_self "$SYNC_SRC" | while read path action file; do

        echo "watch: $path, $action, $file"

        FILEPATH="${path#$SYNC_SRC/}$file"

        # Export vendor/namespace prefix from filepath
        PREFIX="$(echo "$FILEPATH" | cut -d / -f -2)"
        FILEPATH="$(echo "$FILEPATH" | cut -d / -f 3-)"

        case "$action" in
            "DELETE_SELF") ;;
            "DELETE"*)
                /opt/docker/sync/revert-app-symlinks.sh "$PREFIX" "$FILEPATH"
            ;;
            "MOVED_FROM"*)
                /opt/docker/sync/revert-app-symlinks.sh "$PREFIX" "$FILEPATH"
            ;;
            *)
                /opt/docker/sync/create-app-symlinks.sh "$PREFIX" "$FILEPATH"
            ;;
        esac

    done
}

if [ -n "$SYNC_SRC" ]; then
    watch
fi
