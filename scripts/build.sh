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
    ;;

    "magento")
        # pull parent image
        docker pull magently/base:php5

        # build magento images
        echo "Building magento images: $(echo $versions | xargs)"
        for build in $versions; do
            version=$(echo $build | cut -d: -f1)
            tag=$(echo $build | cut -d: -f2)

            echo "Building magento image: $version"

            if [ $(echo "$version" | sed 's/\.//g') -ge 1924 ]; then
                sample_version=1.9.2.4
            elif [ $(echo "$version" | sed 's/\.//g') -ge 1910 ]; then
                sample_version=1.9.1.0
            elif [ $(echo "$version" | sed 's/\.//g') -ge 1900 ]; then
                sample_version=1.9.0.0
            elif [ $(echo "$version" | sed 's/\.//g') -ge 1610 ]; then
                sample_version=1.6.1.0
            else
                sample_version=1.1.2
            fi

            docker build -q \
                --build-arg MAGENTO_VERSION=$version \
                --build-arg MAGENTO_SAMPLE_VERSION=$sample_version \
                -t magently/magento:$version ./docker/magento

            tags+=("magently/magento:$version")

            if [ "$tag" != "$version" ]; then
                echo "Tag: $tag"
                docker tag magently/magento:$version magently/magento:$tag
                tags+=("magently/magento:$tag")
            fi
        done
    ;;

    "magento2-env")
        # pull parent image
        docker pull magently/base:php71

        # build magento2-env image
        echo "Building magento2-env image:"
        docker build -q -t magently/magento2-env ./docker/magento2-env && tags+=("magently/magento2-env")
    ;;

    "magento2")
        # pull parent image
        docker pull magently/magento2-env

        # build magento2 images
        echo "Building magento2 images: $(echo $versions | xargs)"
        for build in $versions; do
            version=$(echo $build | cut -d: -f1)
            tag=$(echo $build | cut -d: -f2)

            echo "Building magento2 image: $version"

            docker build -q \
                --build-arg COMPOSER_AUTH \
                --build-arg MAGENTO_VERSION=$version \
                -t magently/magento2:$version ./docker/magento2

            tags+=("magently/magento2:$version")

            if [ "$tag" != "$version" ]; then
                echo "Tag: $tag"
                docker tag magently/magento2:$version magently/magento2:$tag
                tags+=("magently/magento2:$tag")
            fi
        done
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
