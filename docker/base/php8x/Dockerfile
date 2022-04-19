ARG PHP_VERSION
FROM "webdevops/php-apache-dev:${PHP_VERSION}"

COPY conf/ /opt/docker/

# Add apt sources for nodejs
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

# This is related to this bug: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199
RUN mkdir -p /usr/share/man/man1

RUN apt update && apt -y upgrade
RUN apt -y install \
        openjdk-11-jre-headless \
        ant \
        nodejs \
        mariadb-client \
        patch

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
