#!/bin/bash
set -e

HOST_UID=$(stat -c "%u" "$APPLICATION_PATH")
HOST_GID=$(stat -c "%g" "$APPLICATION_PATH")

groupmod -g $HOST_GID application
usermod -u $HOST_UID application

echo "export APPLICATION_UID=$HOST_UID"
export APPLICATION_UID=$HOST_UID
echo "export APPLICATION_GID=$HOST_GID"
export APPLICATION_GID=$HOST_GID
