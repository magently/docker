#!/bin/bash
set -e

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -p|--publish)
    PUBLISH="1"
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# what to build
to_build="$1"
shift
versions="$@"

# tags for publishing
tags=()

case $to_build in
    "base")
        # build base images
        echo "Building base images:"
        docker build -q -t magently/base:php5 ./docker/base/php5 && tags+=('magently/base:php5')
        docker build -q -t magently/base:php7 ./docker/base/php7 && tags+=('magently/base:php7')
        docker build -q --build-arg PHP_VERSION=7.1 -t magently/base:php71 ./docker/base/php7x && tags+=('magently/base:php71')
        docker build -q --build-arg PHP_VERSION=7.2 -t magently/base:php72 ./docker/base/php7x && tags+=('magently/base:php72')
        docker build -q --build-arg PHP_VERSION=7.3 -t magently/base:php73 ./docker/base/php7x && tags+=('magently/base:php73')
        docker build -q --build-arg PHP_VERSION=7.4 -t magently/base:php74 ./docker/base/php7x && tags+=('magently/base:php74')
    ;;

    "php-test")
        docker build -q \
            -t magently/php-test:7.1 \
            --build-arg php_version=7.1-buster ./docker/php-test && tags+=('magently/php-test:7.1')

        docker build -q \
            -t magently/php-test:7.2 \
            --build-arg php_version=7.2-buster ./docker/php-test && tags+=('magently/php-test:7.2')

        docker build -q \
            -t magently/php-test:7.3 \
            --build-arg php_version=7.3-buster ./docker/php-test && tags+=('magently/php-test:7.3')

        docker build -q \
            -t magently/php-test:7.4 \
            --build-arg php_version=7.4-buster ./docker/php-test && tags+=('magently/php-test:7.4')
    ;;

    *)
        echo "Unknown image $to_build"
        exit 1
esac

# Publish
if [ -n "$PUBLISH" ]; then
    for tag in "${tags[@]}"
    do
        echo "Push: $tag"
        docker push $tag >> /dev/null
    done
fi
