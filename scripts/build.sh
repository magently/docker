#!/bin/bash
set -e

# Set tag
TAG="${DOCKER_TAG:=magently}"

# Build base images
docker build -t $TAG/base:php5 ./docker/base/php5
docker build -t $TAG/base:php7 ./docker/base/php7
