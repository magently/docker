FROM magently/base:php5

ARG MAGENTO_VERSION
ARG MAGENTO_SAMPLE_VERSION

ENV MAGENTO_VERSION=${MAGENTO_VERSION}
ENV MAGENTO_SAMPLE_VERSION=${MAGENTO_SAMPLE_VERSION}

ENV MAGENTO_PATH /var/www/magento
ENV PACKAGES_PATH /app/packages
ENV WEB_DOCUMENT_ROOT /var/www/magento

ENV MAGENTO_LOCALE en_US
ENV MAGENTO_TIMEZONE America/New_York
ENV MAGENTO_DEFAULT_CURRENCY USD
ENV MAGENTO_URL http://localhost

ENV MAGENTO_ADMIN_FIRSTNAME Admin
ENV MAGENTO_ADMIN_LASTNAME MyStore
ENV MAGENTO_ADMIN_EMAIL admin@example.com
ENV MAGENTO_ADMIN_USERNAME admin
ENV MAGENTO_ADMIN_PASSWORD admin123

COPY conf/ /opt/docker/
COPY env/ $APPLICATION_PATH

RUN apt-get update && apt-get -y upgrade

# Add blackfire GPG
RUN wget -q -O - https://packages.blackfire.io/gpg.key | apt-key add - \
    && echo "deb http://packages.blackfire.io/debian any main" | tee /etc/apt/sources.list.d/blackfire.list

# Install dependencies
RUN /usr/local/bin/apt-install \
        # Install patch
        patch \
        # Install mysql-client
        mysql-client \
        # Install inotify-tools
        inotify-tools \

    # Set umask
    && umask 002 \
    && cp /opt/docker/etc/bash.bashrc /etc/bash.bashrc \

    # Prepare www directory
    && chown www-data: /var/www \
    && chmod g+s /var/www \

    # Get magento
    && wget -nv https://github.com/OpenMage/magento-mirror/archive/$MAGENTO_VERSION.tar.gz -O /tmp/magento-$MAGENTO_VERSION.tar.gz \
    && gosu "www-data" tar -xzf /tmp/magento-$MAGENTO_VERSION.tar.gz -C /tmp \
    && mv /tmp/magento-mirror-$MAGENTO_VERSION $MAGENTO_PATH \
    && rm /tmp/magento-$MAGENTO_VERSION.tar.gz \
    && wget -nv https://github.com/magently/magento-compressed-sample-data/raw/master/$MAGENTO_SAMPLE_VERSION/magento-sample-data-$MAGENTO_SAMPLE_VERSION.tar.gz -O /tmp/magento-sample-data-$MAGENTO_SAMPLE_VERSION.tar.gz \
    && gosu "www-data" tar -xzf /tmp/magento-sample-data-$MAGENTO_SAMPLE_VERSION.tar.gz -C /tmp \
    && (cp -a /tmp/magento-sample-data-$MAGENTO_SAMPLE_VERSION/media/. $MAGENTO_PATH/media/ || true) \
    && (cp -a /tmp/magento-sample-data-$MAGENTO_SAMPLE_VERSION/skin/. $MAGENTO_PATH/skin/ || true) \
    && mv /tmp/magento-sample-data-$MAGENTO_SAMPLE_VERSION/magento_sample_data_for_$MAGENTO_SAMPLE_VERSION.sql $MAGENTO_PATH \
    && chmod g+w -R $MAGENTO_PATH \
    && rm /tmp/magento-sample-data-$MAGENTO_SAMPLE_VERSION.tar.gz \
    && rm -r /tmp/magento-sample-data-$MAGENTO_SAMPLE_VERSION \

    # Apply magento patches
    &&  find "/opt/docker/magento/patches" -type f -name "*.patch" | \
        sed "s#\(^/opt/docker/magento/patches/\|\.patch$\)##g" | \
        while read patch; do \
          # Check if $MAGENTO_VERSION matches patch version range
          if [ "$MAGENTO_VERSION" = "$({ echo "$MAGENTO_VERSION"; echo "$patch" | sed 's#^magento-\(\([0-9]\.\)\{1,3\}[0-9]\)--\(\([0-9]\.\)\{1,3\}[0-9]\)-.\+$#\1\n\3#i'; } | sort -V | xargs | cut -d" " -f2)" ]; then \
            # Apply patch
            echo "Applying patch: $patch" \
            && gosu "www-data" patch -d "$MAGENTO_PATH" -p1 < "/opt/docker/magento/patches/$patch.patch"; \
          fi \
        done \

    # Install magento crontab
    && cat /opt/docker/magento/crontab | crontab - \

    # Clean up
    && docker-image-cleanup
