FROM webdevops/php-apache-dev:debian-9

COPY conf/ /opt/docker/

# Add apt sources for nodejs
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN /usr/local/bin/apt-install \
        # Install java
        openjdk-8-jre-headless \
        # Install ant
        ant \
        # Install nodejs
        nodejs \
        # Install mysql-client
        mysql-client \
        # Install patch
        patch

# Install node LTS
RUN npm install -g n \
    && n lts \
    && npm update -g npm \
    && docker-image-cleanup

ENV DOCKERIZE_VERSION v0.6.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN composer self-update --1

RUN adduser www-data application \
    && adduser application www-data

# Disable memory limit in PHP-CLI
RUN sed -i 's/^memory_limit\s*=.*$/memory_limit = -1/' /etc/php/7.0/cli/conf.d/98-webdevops.ini
