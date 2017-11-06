FROM magently/magento2-env

ARG COMPOSER_AUTH
ARG MAGENTO_VERSION

ENV PACKAGES_PATH=/app/packages

COPY conf/ /opt/docker/

RUN \
    # Set umask
    umask 002 \
    # Get magento
    && gosu "www-data" bash -c "cd /var/www \
        && composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition $MAGENTO_PATH `[ $MAGENTO_VERSION = 'latest' ] && echo '' || echo '$MAGENTO_VERSION'` 2>/dev/null" \
    # Install functional tests dependencies
    && gosu "www-data" composer install -q -d "$MAGENTO_PATH/dev/tests/functional" \
    # Clean up composer cache
    && rm -r /var/www/.composer \
    # Apply magento patches
    && find "/opt/docker/magento/patches" -type f -name "*.patch" | \
        sed "s#\(^/opt/docker/magento/patches/\|\.patch$\)##g" | \
        while read patch; do \
          patch "$MAGENTO_PATH/$patch" "/opt/docker/magento/patches/$patch.patch"; \
        done \
    # Clean up
    && docker-image-cleanup
