#!/bin/bash
set -e

if [ -z "${COMPOSER_VERSION}" ]
then
    COMPOSER_VERSION=1
fi

composer self-update --"$COMPOSER_VERSION"
