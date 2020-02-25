#!/bin/bash

MYSQL=`which mysql`
WGET=`which wget`
SED=`which sed`
RSYNC=`which rsync`
TAR=`which tar`
COMPOSER=`which composer`
DB_USER=$1
DB_PASS=$2
DB_HOST=$3
DB_NAME=$4
MG_ADMIN=$5
ENV_URL=$6
USER_EMAIL=$7

MG_PATH=${SERVER_WEBROOT}
rm -rf ${MG_PATH}/*

VERSION=$(curl --silent "https://api.github.com/repos/magento/magento2/releases" | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/' | sort -r | head -n 1)
$WGET https://github.com/magento/magento2/archive/${VERSION}.tar.gz -O /tmp/${VERSION}.tgz
$TAR -C "/tmp" -xpzf "/tmp/${VERSION}.tgz";
$RSYNC -au --remove-source-files /tmp/magento2-${VERSION}/ ${MG_PATH}/
$COMPOSER update --working-dir=${MG_PATH}
$MYSQL -u${DB_USER} -p${DB_PASS} -h ${DB_HOST} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"

php ${MG_PATH}/bin/magento setup:install -s \
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
