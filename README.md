# Magently Docker Images

Docker images based on [WebDevOps Dockerfile](https://github.com/webdevops/Dockerfile)
providing docker environment for PHP apps.

## Image types

### Base

* Built from 'webdevops/php-apache:debian-8' or
  'webdevops/php-apache:debian-8-php7'
* Webserver runs with UID:GID of /app directory
* Triggers `ant work` on start
* Includes 'dockerize', 'node', 'java jre' and 'mysql client'

Is is important to notice that this image is not meant to run with root
permission, the main strength of this image is to provide environment which
can be used with user permissions (usally with developer/CI ownership) without
pain of files ownership conflicts.

Given /app with user:group ownership all web-server-generated files will be
created with the same user:group ownership.

Please run all app related scripts using `gosu application` wrapper, f.e.:
`gosu application composer require --dev phpunit/phpunit`.

#### Usage

Assuming your app is placed in `app` directory and it contains a `build.xml`
file, you can run this container with following `docker-compose` config:

~~~
version: '2'

services:
  app:
    build: ./docker/base/php5
    ports:
      - 80:80
    volumes:
      - ./app:/app

  db:
    image: mysql:5.7
~~~
