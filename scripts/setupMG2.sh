#!/bin/bash

MYSQL=`which mysql`
SED=`which sed`
DB_USER=$1
DB_PASS=$2
DB_HOST=$3
DB_NAME=$4
MG_ADMIN=$5
MG_PATH=$6
ENV_URL=$7
USER_EMAIL=$8

$MYSQL -u${DB_USER} -p${DB_PASS} -h ${DB_HOST} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"

php -f ${MG_PATH}/bin/magento setup:install -s \
--backend-frontname=admin \
--db-host=${DB_HOST} \
--db-name=${DB_NAME} \
--db-user=${DB_USER} \
--db-password=${DB_PASS} \
--base-url=${ENV_URL} \
--admin-firstname=Admin \
--admin-lastname=AdminLast \
--admin-email=${USER_EMAIL} \
--admin-user=admin \
--admin-password=${MG_ADMIN};

$MYSQL -u${DB_USER} -p${DB_PASS} -h ${DB_HOST} ${DB_NAME} -e \
"INSERT INTO core_config_data ( scope, scope_id, path, value ) VALUES ( 'default', '0', 'system/full_page_cache/caching_application', '2') ON DUPLICATE KEY UPDATE value = 2;"

php ${MG_PATH}/bin/magento indexer:reindex;
php ${MG_PATH}/bin/magento cache:flush

chown nginx:nginx -Rh ${MG_PATH}
