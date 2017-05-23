#!/bin/bash
set -e

# Build base images
docker build -t magently/base:php5 ./docker/base/php5
docker build -t magently/base:php7 ./docker/base/php7

# Build magento image
docker build \
    --build-arg MAGENTO_VERSION=1.9.2.0 \
    --build-arg MAGENTO_SAMPLE_VERSION=1.9.1.0 \
    -t magently/magento ./docker/magento

# Build magento2-env image
docker build -t magently/magento2-env ./docker/magento2-env

# Build magento2 images
MAGENTO2_VERSIONS=${MAGENTO2_VERSIONS:=latest}
for MAGENTO_VERSION in $MAGENTO2_VERSIONS; do
    docker build \
        --build-arg COMPOSER_AUTH \
        --build-arg MAGENTO_VERSION=$MAGENTO_VERSION\
        -t magently/magento2:$MAGENTO_VERSION \
        ./docker/magento2
done
