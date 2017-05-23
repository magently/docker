#!/bin/bash
set -e

# Wait for database
dockerize -timeout 30s -wait tcp://$MYSQL_HOST:3306

if [ ! -e $MAGENTO_PATH/app/etc/local.xml ]; then
  # Install sample data
  mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < "$MAGENTO_PATH/magento_sample_data_for_$MAGENTO_SAMPLE_VERSION.sql"

  # Install Magento
  gosu "application" php "$MAGENTO_PATH/install.php" -- \
    --license_agreement_accepted "yes" \
    --locale $MAGENTO_LOCALE \
    --timezone $MAGENTO_TIMEZONE \
    --default_currency $MAGENTO_DEFAULT_CURRENCY \
    --db_host $MYSQL_HOST \
    --db_name $MYSQL_DATABASE \
    --db_user $MYSQL_USER \
    --db_pass $MYSQL_PASSWORD \
    --url $MAGENTO_URL \
    --skip_url_validation "yes" \
    --use_rewrites "no" \
    --use_secure "no" \
    --secure_base_url "" \
    --use_secure_admin "no" \
    --admin_firstname $MAGENTO_ADMIN_FIRSTNAME \
    --admin_lastname $MAGENTO_ADMIN_LASTNAME \
    --admin_email $MAGENTO_ADMIN_EMAIL \
    --admin_username $MAGENTO_ADMIN_USERNAME \
    --admin_password $MAGENTO_ADMIN_PASSWORD \
    || true

  # Set up timezone
  sed -i "s#date\.timezone = .*#date.timezone = $MAGENTO_TIMEZONE#" /opt/docker/etc/php/php.webdevops.ini
fi
