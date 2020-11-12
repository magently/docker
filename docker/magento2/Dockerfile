FROM magently/magento2-env

ARG COMPOSER_AUTH
ARG MAGENTO_VERSION

ENV PACKAGES_PATH=/var/www/magento/packages

COPY conf/ /opt/docker/

RUN umask 002
RUN cd /var/www && COMPOSER_MEMORY_LIMIT=4G gosu www-data composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition $MAGENTO_PATH `[ $MAGENTO_VERSION = 'latest' ] && echo '' || echo $MAGENTO_VERSION`

# Install functional tests dependencies
RUN gosu "www-data" composer install -q -d "$MAGENTO_PATH/dev/tests/functional"

# Require phpunit/phpcov globally
RUN php_code_coverage_version=
RUN gosu "www-data" bash -c "composer global require phpunit/php-code-coverage:$(gosu "www-data" bash -c "cd $MAGENTO_PATH && composer show phpunit/php-code-coverage | grep 'versions :' | cut -d ' ' -f4") phpunit/phpcov:*"

# Clean up composer cache
RUN rm -r /var/www/.composer/cache

# Apply magento patches
RUN find "/opt/docker/magento/patches" -type f -name "*.patch" | \
        sed "s#\(^/opt/docker/magento/patches/\|\.patch$\)##g" | \
        while read patch; do \
          patch "$MAGENTO_PATH/$patch" "/opt/docker/magento/patches/$patch.patch"; \
        done

# Clean up
RUN docker-image-cleanup
