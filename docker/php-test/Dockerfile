ARG php_version
FROM "php:${php_version}"

# Install dependencies
RUN apt-get update && apt-get install -y libldap2-dev wget git unzip libpng-dev libzip-dev ant

# Install MySQL extension
RUN docker-php-ext-configure pdo_mysql \
    && docker-php-ext-install -j$(nproc) pdo_mysql

# Install LDAP extension
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) ldap

# Install BCMATH extension
RUN docker-php-ext-configure bcmath --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) bcmath

# Install GD extension
RUN docker-php-ext-configure gd --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) gd

# Install iconv extension
RUN docker-php-ext-configure iconv --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) iconv

# Install ZIP extension
RUN docker-php-ext-configure zip --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) zip

# Install Calendar extension
RUN docker-php-ext-configure calendar --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) calendar

# Install Dockerize
RUN wget https://github.com/jwilder/dockerize/releases/download/v0.6.0/dockerize-linux-amd64-v0.6.0.tar.gz -O dockerize.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize.tar.gz \
    && rm dockerize.tar.gz

RUN mkdir /opt/docker
RUN chmod 777 /opt/docker

# Install Composer
COPY composer.sh /opt/docker/composer.sh
RUN bash /opt/docker/composer.sh && rm /opt/docker/composer.sh

# Execute install script and run service
WORKDIR /app
ENTRYPOINT ["/usr/local/bin/docker-php-entrypoint"]
CMD ["php"]
