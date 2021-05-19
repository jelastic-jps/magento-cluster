#!/bin/bash -e

MAGENTO_DIR=/var/www/webroot/ROOT
MAGENTO_BIN="php ${MAGENTO_DIR}/bin/magento"
LOG=/var/log/run.log
MYSQL=`which mysql`
SED=`which sed`
WGET=`which wget`
RSYNC=`which rsync`
TAR=`which tar`
COMPOSER=`which composer`


install(){
    ARGUMENT_LIST=(
        "base-url"
        "db-host"
        "db-name"
        "db-user"
        "db-password"
        "admin-email"
        "admin-password"
        "elasticsearch-host"
        "elasticsearch-port"
        "elasticsearch-username"
        "elasticsearch-password"
        "cache-backend"
        "cache-backend-redis-server"
        "cache-backend-redis-port"
        "cache-backend-redis-db"
        "session-save"
        "session-save-redis-host"
        "session-save-redis-port"
        "session-save-redis-db"
    )

    opts=$(getopt \
        --longoptions "$(printf "%s:," "${ARGUMENT_LIST[@]}")" \
        --name "$(basename "$0")" \
        --options "" \
        -- "$@"
    )
    eval set --$opts

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --base-url)
                base_url=$2
                shift 2
                ;;
            --db-host)
                db_host=$2
                shift 2
                ;;
            --db-name)
                db_name=$2
                shift 2
                ;;
            --db-user)
                db_user=$2
                shift 2
                ;;
            --db-password)
                db_password=$2
                shift 2
                ;;
            --admin-email)
                admin_email=$2
                shift 2
                ;;
            --admin-password)
                admin_password=$2
                shift 2
                ;;
            --elasticsearch-host)
                elasticsearch_host=$2
                shift 2
                ;;
            --elasticsearch-port)
                elasticsearch_port=$2
                shift 2
                ;;
            --elasticsearch-username)
                elasticsearch_username=$2
                shift 2
                ;;
            --elasticsearch-password)
                elasticsearch_password=$2
                shift 2
                ;;
            --cache-backend)
                cache_backend=$2
                shift 2
                ;;
            --cache-backend-redis-server)
                cache_backend_redis_server=$2
                shift 2
                ;;
            --cache-backend-redis-port)
                cache_backend_redis_port=$2
                shift 2
                ;;
            --cache-backend-redis-db)
                cache_backend_redis_db=$2
                shift 2
                ;;
            --session-save)
                session_save=$2
                shift 2
                ;;
            --session-save-redis-host)
                session_save_redis_host=$2
                shift 2
                ;;
            --session-save-redis-port)
                session_save_redis_port=$2
                shift 2
                ;;
            --session-save-redis-db)
                session_save_redis_db=$2
                shift 2
                ;;
        *)
            break
            ;;
        esac
    done

    $MYSQL -u${db_user} -p${db_password} -h ${db_host} -e "CREATE DATABASE IF NOT EXISTS ${db_name};"

    ${MAGENTO_BIN} setup:install -s \
        --backend-frontname=admin \
        --db-host=${db_host} \
        --db-name=${db_name} \
        --db-user=${db_user} \
        --db-password=${db_password} \
        --elasticsearch-host=${elasticsearch_host} \
        --elasticsearch-username=${elasticsearch_username} \
        --elasticsearch-password=${elasticsearch_password} \
        --elasticsearch-enable-auth=1 \
        --cache-backend=${cache_backend} \
        --cache-backend-redis-server=${cache_backend_redis_server} \
        --cache-backend-redis-db=${cache_backend_redis_db} \
        --cache-backend-redis-port=${cache_backend_redis_port} \
        --session-save=${session_save} \
        --session-save-redis-host=${session_save_redis_host} \
        --session-save-redis-port=${session_save_redis_port} \
        --session-save-redis-db=${session_save_redis_db} \
        --base-url=${base_url} \
        --admin-firstname=Admin \
        --admin-lastname=AdminLast \
        --admin-email=${admin_email} \
        --admin-user=admin \
        --admin-password=${admin_password};
}

litemage(){
    if [ $2 == 'ON' ] ; then
        loop_limit=10
        for (( i=0 ; i<${loop_limit} ; i++ )); do
            version=$(curl --silent "https://api.github.com/repos/litespeedtech/magento2-LiteSpeed_LiteMage/releases" | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/' | sort -r | head -n 1);
            short_version=$(echo ${version} | sed 's/v//');
            $WGET https://github.com/litespeedtech/magento2-LiteSpeed_LiteMage/archive/${version}.tar.gz -O /tmp/${version}.tgz;
            [ $? == 0 ] && break;
            sleep 6
        done

        $TAR -C "/tmp" -xpzf "/tmp/${version}.tgz";
        [ -d ${MAGENTO_DIR}/app/code/Litespeed/Litemage ] || mkdir -p ${MAGENTO_DIR}/app/code/Litespeed/Litemage;
        $RSYNC -au --remove-source-files /tmp/magento2-LiteSpeed_LiteMage-${short_version}/ ${MAGENTO_DIR}/app/code/Litespeed/Litemage/;
        ${MAGENTO_BIN} module:enable Litespeed_Litemage &>> $LOG;
        ${MAGENTO_BIN} setup:upgrade &>>$LOG;
        ${MAGENTO_BIN} config:set system/full_page_cache/caching_application LITEMAGE &>>$LOG;
    fi
}

case ${1} in
    install)
        install "$@"
        ;;

    litemage)
        litemage "$@"
        ;;
esac
