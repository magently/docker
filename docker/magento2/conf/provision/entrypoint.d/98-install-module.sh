#!/bin/bash
set -e
umask 002

# Discover packages
packages="$(find "$PACKAGES_PATH" -maxdepth 3 -type f -name composer.json \
    -exec grep -Po '"name":\s*"[^"/]+/[^"/]+"' {} \; \
    | cut -d: -f2 | tr -d ' "' | xargs)"

# Require packages
gosu "application" composer config -d "$MAGENTO_PATH" repositories.1 "{\"type\": \"path\", \"url\": \"$PACKAGES_PATH/*/*\"}" 2>/dev/null
[ -n "$packages" ] && gosu "application" composer require -d "$MAGENTO_PATH" $packages

# Wait for database
dockerize -timeout 30s -wait tcp://$MYSQL_HOST:3306
