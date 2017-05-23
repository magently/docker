FROM webdevops/php-apache-dev:debian-8-php7

COPY conf/ /opt/docker/

RUN /usr/local/bin/apt-install \
        # Install java
        openjdk-7-jre-headless \
        # Install ant
        ant \
        # Install npm
        npm \
        # Install mysql-client
        mysql-client \
        # Install patch
        patch \
    # Install node LTS
    && npm install -g n \
    && n lts \
    && npm update -g npm \
    && docker-image-cleanup

ENV DOCKERIZE_VERSION v0.4.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN adduser www-data application \
    && adduser application www-data
