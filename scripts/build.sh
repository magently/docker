#!/bin/bash
set -e

# Build base images
docker build -t magently/base:php5 ./docker/base/php5
docker build -t magently/base:php7 ./docker/base/php7

# Build magento2-env image
docker build -t magently/magento2-env ./docker/magento2-env
