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
php -f ${MG_PATH}/install.php -- \
--license_agreement_accepted "yes" \
--locale "en_US" \
--timezone "America/Los_Angeles" \
--default_currency "USD" \
--db_host ${DB_HOST} \
--db_name ${DB_NAME} \
--db_user ${DB_USER} \
--db_pass ${DB_PASS} \
--url ${ENV_URL} \
--skip_url_validation "yes" \
--use_rewrites "no" \
--use_secure "no" \
--secure_base_url "" \
--use_secure_admin "no" \
--admin_firstname Admin \
--admin_lastname AdminLast \
--admin_email ${USER_EMAIL} \
--admin_username admin \
--admin_password ${MG_ADMIN};
#$SED -i 's|getBlock(\$callback\[0\])->\$callback\[1\]|getBlock(\$callback\[0\])->{\$callback\[1\]}|g' ${MG_PATH}/app/code/core/Mage/Core/Model/Layout.php;
$SED -i 's|false|true|g' ${MG_PATH}/app/etc/modules/Cm_RedisSession.xml;
$MYSQL -u${DB_USER} -p${DB_PASS} -h ${DB_HOST} -e "INSERT INTO ${DB_NAME}.core_config_data (path,value) VALUES ('admin/security/validate_formkey_checkout',1);";
php -f ${MG_PATH}/shell/indexer.php reindexall;
rm -rf ${MG_PATH}/var/cache;
