#!/bin/bash
set -e

# Set tag
TAG="${DOCKER_TAG:=magently}"

# Set registry
REGISTRY="${DOCKER_REGISTRY:=registry.magently.com}"

# Tag images
docker tag $TAG/base:php5 $REGISTRY/$TAG/base:php5
docker tag $TAG/base:php7 $REGISTRY/$TAG/base:php7

# Publish images
docker push $REGISTRY/$TAG/base:php5
docker push $REGISTRY/$TAG/base:php7
