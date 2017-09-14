#!/bin/bash
set -e

# Install composer dependencies
gosu "application" composer install -d "$MAGENTO_PATH"

# Inject templates
find "/opt/docker/magento/templates" -type f -name "*.tmpl" | sed "s#\(^/opt/docker/magento/templates/\|\.tmpl$\)##g" | while read tpl; do
  gosu "application" dockerize -template "/opt/docker/magento/templates/$tpl.tmpl:$MAGENTO_PATH/$tpl"
done

# Wait for database
dockerize -timeout 30s -wait tcp://$MYSQL_HOST:3306

# Install Magento 2
gosu "application" php "$MAGENTO_PATH/bin/magento" setup:install \
  --base-url=$MAGENTO_URL \
  --backend-frontname=$MAGENTO_BACKEND_FRONTNAME \
  --language=$MAGENTO_LANGUAGE \
  --timezone=$MAGENTO_TIMEZONE \
  --currency=$MAGENTO_DEFAULT_CURRENCY \
  --db-host=$MYSQL_HOST \
  --db-name=$MYSQL_DATABASE \
  --db-user=$MYSQL_USER \
  --db-password=$MYSQL_PASSWORD \
  --use-secure=0 \
  --base-url-secure=0 \
  --use-secure-admin=0 \
  --admin-firstname=$MAGENTO_ADMIN_FIRSTNAME \
  --admin-lastname=$MAGENTO_ADMIN_LASTNAME \
  --admin-email=$MAGENTO_ADMIN_EMAIL \
  --admin-user=$MAGENTO_ADMIN_USERNAME \
  --admin-password=$MAGENTO_ADMIN_PASSWORD

# Enable template symlinks
mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE \
  -e "insert into core_config_data values (null, 'default', 0, 'dev/template/allow_symlink', 1) on duplicate key update value = 1;"

# Create `magento_integration_tests` database
mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD \
  -e 'create database if not exists `magento_integration_tests`;'

# Prepare Magento configuration for functional tests
mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE \
  -e "insert into core_config_data values (null, 'default', 0, 'admin/security/use_form_key', 0) on duplicate key update value = 0;" \
  -e "insert into core_config_data values (null, 'default', 0, 'cms/wysiwyg/enabled', 'disabled') on duplicate key update value = 'disabled';"

# Install functional tests dependencies
[ -e "$MAGENTO_PATH/dev/tests/functional/vendor" ] || gosu "application" composer install -d "$MAGENTO_PATH/dev/tests/functional"
