FROM magently/base:php71

ENV MAGENTO_PATH /var/www/magento
ENV WEB_DOCUMENT_ROOT /var/www/magento/pub

ENV MAGENTO_LANGUAGE en_US
ENV MAGENTO_TIMEZONE Europe/Warsaw
ENV MAGENTO_DEFAULT_CURRENCY USD
ENV MAGENTO_URL http://magento.localhost
ENV MAGENTO_BACKEND_FRONTNAME admin

ENV MAGENTO_ADMIN_FIRSTNAME Admin
ENV MAGENTO_ADMIN_LASTNAME MyStore
ENV MAGENTO_ADMIN_EMAIL admin@example.com
ENV MAGENTO_ADMIN_USERNAME admin
ENV MAGENTO_ADMIN_PASSWORD admin123

ENV MAGENTO_TEST_CLEANUP=0

COPY conf/ /opt/docker/
COPY env/ $APPLICATION_PATH

RUN \
    # Install dependencies
    /usr/local/bin/apt-install \
        # Install patch
        patch \
        # Install mysql-client
        mysql-client \
        # Install json cli
        jq \

    # Prepare www directory
    && chown www-data: /var/www \
    && chmod g+s /var/www \

    # Make script executable
    && chmod +x /opt/docker/magento/bin/* \

    # Set umask
    && umask 002 \
    && cp /opt/docker/etc/bash.bashrc /etc/bash.bashrc \
    # Install magento crontab
    && cat /opt/docker/magento/crontab | crontab - \
    # Clean up
    && docker-image-cleanup
