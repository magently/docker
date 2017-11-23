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
    # Require phpunit/phpcov globally \
    && php_code_coverage_version=$(gosu "www-data" bash -c "cd $MAGENTO_PATH && composer show phpunit/php-code-coverage | grep 'versions :' | cut -d ' ' -f4") \
    && gosu "www-data" bash -c "composer global require phpunit/php-code-coverage:$php_code_coverage_version phpunit/phpcov:*" \
    # Clean up composer cache
    && rm -r /var/www/.composer/cache \
    # Apply magento patches
    && find "/opt/docker/magento/patches" -type f -name "*.patch" | \
        sed "s#\(^/opt/docker/magento/patches/\|\.patch$\)##g" | \
        while read patch; do \
          patch "$MAGENTO_PATH/$patch" "/opt/docker/magento/patches/$patch.patch"; \
        done \
    # Clean up
    && docker-image-cleanup
