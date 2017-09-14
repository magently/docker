#!/bin/bash
set -e

# Publish images
docker push magently/base:php5
docker push magently/base:php7

# Publish magento2-env image
docker push magently/magento2-env
