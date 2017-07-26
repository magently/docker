#!/bin/bash
set -e

# Set registry
REGISTRY="${DOCKER_REGISTRY:=registry.magently.com}"

# Tag images
docker tag magently/base:php5 $REGISTRY/magently/base:php5
docker tag magently/base:php7 $REGISTRY/magently/base:php7

# Publish images
docker push $REGISTRY/magently/base:php5
docker push $REGISTRY/magently/base:php7
