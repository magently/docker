#!/bin/bash
set -e

# Fix bin/magento permission issues
# Magento 2.2.0+ executes chmod o bin/magento during composer install
chown "application" "$MAGENTO_PATH/bin/magento"
