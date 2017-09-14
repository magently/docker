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

## Magento2-env

* Built from 'magently/base:php-7'
* Triggers Magento setup on start
* Magento should be mounted in /var/www/magento directory
* Pre-configured static-analysis
* Pre-configured tests

This image is tuned to run Magento with lowest effort.

#### Usage

Assuming directory structure like below:

* docker-compose.yml
* project             - magento root directory
* packages            - additional magento packages
  + namespace/name1
  + ...

You can run this image with following `docker-compose` config:

~~~
version: '2'

services:
  # MySQL container
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: db

  # App container
  app:
    image: magently/magento2-env
    links:
      - db
    ports:
      - 80:80
    volumes:
      - ./project/:/var/www/magento/
      - ./packages/:/app/packages/
    environment:
      - MYSQL_HOST=db
      - MYSQL_USER=root
      - MYSQL_PASSWORD=secret
      - MYSQL_DATABASE=db
      - COMPOSER_AUTH={"http-basic":{"repo.magento.com":{"username":"<username>","password":"<password>"}}}

  ##
  # OPTIONALLY FOR FUNCTIONAL TESTING
  # MERGE DIRECTIVES BELOW:
  ##
    volumes:
      - ./path/to/custom/credentials.xml.tmpl:/opt/docker/magento/templates/dev/tests/functional/credentials.xml.tmpl
      - ./packages/path/to/package/Test/functional:/var/www/magento/dev/tests/functional/tests/app/<vendor>/<namespace>/Test
    environment:
      - SELENIUM_HOST=hub
      - SELENIUM_PORT=4444
      - SELENIUM_BROWSER=Mozilla Firefox
      - SELENIUM_BROWSER_NAME=firefox
    extra_hosts:
      - "magento.localhost:127.0.0.1"

  # Selenium container
  hub:
    image: selenium/hub:2.53.1
    links:
      - app:magento.localhost

  firefox:
    image: selenium/node-firefox:2.53.1
    links:
      - hub
    environment:
      HUB_PORT_4444_TCP_ADDR: hub
      HUB_PORT_4444_TCP_PORT: 4444
~~~

Having this set up you can run static-analysis and tests on
every package in `./packages` directory:

~~~
$ docker-compose exec bash -c 'cd /app && gosu application composer run-script test'
~~~

## Magento2

* Built from 'magently/magento2-env'
* Pre-installed Magento in /var/www/magento
* Installs all packages on start located in /app/packages

This images are meant for Magento 2 integrating, you can
test your packages with various Magento 2 versions easily
with this image.

#### Tags

- latest - Image with latest Magento 2
- 2.X.Y  - Image with Magento 2.X.Y

#### Usage

Assuming directory structure like below:

* docker-compose.yml
* packages            - additional magento packages
  + namespace/name1
  + ...

You can run this image with following `docker-compose` config:

~~~
version: '2'

services:
  # MySQL container
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: db

  # App container
  app:
    image: magently/magento2
    links:
      - db
    ports:
      - 80:80
    volumes:
      - ./packages/:/app/packages/
    environment:
      - MYSQL_HOST=db
      - MYSQL_USER=root
      - MYSQL_PASSWORD=secret
      - MYSQL_DATABASE=db

  ##
  # OPTIONALLY FOR FUNCTIONAL TESTING:
  ##

      - SELENIUM_HOST=hub
      - SELENIUM_PORT=4444
      - SELENIUM_BROWSER=Mozilla Firefox
      - SELENIUM_BROWSER_NAME=firefox
    extra_hosts:
      - "magento.localhost:127.0.0.1"

  # Selenium container
  hub:
    image: selenium/hub:2.53.1
    links:
      - app:magento.localhost

  firefox:
    image: selenium/node-firefox:2.53.1
    links:
      - hub
    environment:
      HUB_PORT_4444_TCP_ADDR: hub
      HUB_PORT_4444_TCP_PORT: 4444
~~~

Having this set up you can run static-analysis and tests on
every package in `./packages` directory:

~~~
$ docker-compose exec bash -c 'cd /app && gosu application composer run-script test'
~~~
