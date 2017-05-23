#!/bin/bash
set -e

# Publish images
docker push magently/base:php5
docker push magently/base:php7

# Publish magento image
docker push magently/magento

# Publish magento2-env image
docker push magently/magento2-env

# Publish magento2 images
MAGENTO2_VERSIONS=${MAGENTO2_VERSIONS:=latest}
for MAGENTO_VERSION in $MAGENTO2_VERSIONS; do
    docker push magently/magento2:$MAGENTO_VERSION
done
