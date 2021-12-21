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

    echo $(date -u) "Create magento database" >>$LOG;
    $MYSQL -u${db_user} -p${db_password} -h ${db_host} -e "CREATE DATABASE IF NOT EXISTS ${db_name};"

    echo $(date -u) "Begin magento installation" >>$LOG;
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
        --admin-password=${admin_password} \
        --disable-modules 'Magento_TwoFactorAuth,Magento_Csp' &>> $LOG;

     echo $(date -u) "End magento installation" >>$LOG;

    ${MAGENTO_BIN} index:reindex;
}

litemage(){
    if [ $2 == 'on' ] ; then
        loop_limit=10
        for (( i=0 ; i<${loop_limit} ; i++ )); do
            version=$(curl --silent "https://api.github.com/repos/litespeedtech/magento2-LiteSpeed_LiteMage/releases" | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/' | sort -r | head -n 1);
            short_version=$(echo ${version} | sed 's/v//');
            $WGET https://github.com/litespeedtech/magento2-LiteSpeed_LiteMage/archive/${version}.tar.gz -O /tmp/${version}.tgz;
            [ $? == 0 ] && break;
            sleep 6
        done

        echo $(date -u) "Begin latemage setup" >>$LOG;
        $TAR -C "/tmp" -xpzf "/tmp/${version}.tgz";
        [ -d ${MAGENTO_DIR}/app/code/Litespeed/Litemage ] || mkdir -p ${MAGENTO_DIR}/app/code/Litespeed/Litemage;
        $RSYNC -au --remove-source-files /tmp/magento2-LiteSpeed_LiteMage-${short_version}/ ${MAGENTO_DIR}/app/code/Litespeed/Litemage/;
        ${MAGENTO_BIN} module:enable Litespeed_Litemage &>> $LOG;
        ${MAGENTO_BIN} setup:upgrade &>>$LOG;
        ${MAGENTO_BIN} setup:di:compile &>>$LOG;
        [ -f ${MAGENTO_DIR}/var/di/relations.ser ] && rm -f ${MAGENTO_DIR}/var/di/relations.ser;
        ${MAGENTO_BIN} config:set system/full_page_cache/caching_application LITEMAGE &>>$LOG;
        echo $(date -u) "End latemage setup" >>$LOG;
    fi
}

varnish(){
    if [ $2 == 'on' ] ; then
        echo $(date -u) "Begin varnish setup" >>$LOG;
        ${MAGENTO_BIN} config:set system/full_page_cache/caching_application 2 &>>$LOG;
        echo $(date -u) "End varnish setup" >>$LOG;
    fi
}

ssl(){
    if [ $2 == 'on' ] ; then
        echo $(date -u) "Begin SSL setup" >>$LOG;
        host=$(${MAGENTO_BIN} config:show web/unsecure/base_url | cut -d'/' -f3);
        ${MAGENTO_BIN} config:set web/secure/base_url https://${host}/ &>>$LOG;
        ${MAGENTO_BIN} config:set web/secure/use_in_frontend 1 &>>$LOG;
        ${MAGENTO_BIN} config:set web/secure/use_in_adminhtml 1 &>>$LOG;
        ${MAGENTO_BIN} config:set web/secure/enable_hsts 1 &>>$LOG;
        ${MAGENTO_BIN} cache:flush;
        echo $(date -u) "Begin SSL setup" >>$LOG;
    fi
}

domain(){
    echo $(date -u) "Begin ${2} DOMAIN setup" >>$LOG;
    [ "$(${MAGENTO_BIN} config:show web/unsecure/base_url)" != ""  ] && ${MAGENTO_BIN} config:set web/unsecure/base_url http://${2}/ &>>$LOG;
    [ "$(${MAGENTO_BIN} config:show web/secure/base_url)" != ""  ] && ${MAGENTO_BIN} config:set web/secure/base_url https://${2}/ &>>$LOG;
    [ "$(${MAGENTO_BIN} config:show web/secure/use_in_frontend)" != ""  ] && ${MAGENTO_BIN} config:set web/secure/use_in_frontend 1 &>>$LOG;
    [ "$(${MAGENTO_BIN} config:show web/secure/use_in_adminhtml)" != ""  ] && ${MAGENTO_BIN} config:set web/secure/use_in_adminhtml 1 &>>$LOG;
    [ "$(${MAGENTO_BIN} config:show web/secure/enable_hsts)" != ""  ] && ${MAGENTO_BIN} config:set web/secure/enable_hsts 1 &>>$LOG;
    ${MAGENTO_BIN} cache:flush;
    echo $(date -u) "End ${2} DOMAIN setup" >>$LOG;
}

baseUrl(){
    echo $(date -u) "Begin ${2} baseUrl setup" >>$LOG;
    domain=$(echo ${2} | sed '/\/$/! s|$|/|')
    ${MAGENTO_BIN} config:set web/unsecure/base_url ${domain} &>>$LOG;
    ${MAGENTO_BIN} config:set web/secure/base_url ${domain} &>>$LOG;
    ${MAGENTO_BIN} cache:flush;
    echo $(date -u) "End ${2} baseUrl setup" >>$LOG;
}

cors(){
    if [ $2 == 'on' ] ; then
        echo $(date -u) "Begin CORS setup" >>$LOG;
        for file in ${MAGENTO_DIR}/pub/.htaccess ${MAGENTO_DIR}/.htaccess; do
            cat >> ${file} <<EOF
<IfModule mod_headers.c>
  <FilesMatch "\.(eot|ttf|ttc|otf|woff|woff2|html|js|iframe|font.css|css|ico|json)$">
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "POST, GET, OPTIONS, DELETE, PUT"
    Header set Access-Control-Allow-Headers "x-requested-with"
  </FilesMatch>
</IfModule>

EOF
        done
        echo $(date -u) "End CORS setup" >>$LOG;
    fi
}

edgeportCDN(){

    ARGUMENT_LIST=(
        "cdn-url"
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
            --cdn-url)
                cdn_url=$2
                shift 2
                ;;
        *)
            break
            ;;
        esac
    done

    echo $(date -u) "Begin CDN reset values" >>$LOG;
    ${MAGENTO_BIN} config:set web/unsecure/base_static_url "" &>> /var/log/run.log
    ${MAGENTO_BIN} config:set web/unsecure/base_media_url "" &>> /var/log/run.log
    ${MAGENTO_BIN} config:set web/secure/base_static_url "" &>> /var/log/run.log
    ${MAGENTO_BIN} config:set web/secure/base_media_url "" &>> /var/log/run.log
    ${MAGENTO_BIN} cache:flush &>> /var/log/run.log
    echo $(date -u) "End CDN reset values" >>$LOG;

    echo $(date -u) "Begin ${2} CDN setup" >>$LOG;

    [ -f ~/checkCdnContent.txt ] && rm -f ~/checkCdnContent.txt;
    base_url=$(${MAGENTO_BIN} config:show web/unsecure/base_url);
    wget ${base_url} -O /tmp/index.html;
    cat /tmp/index.html | \
        sed 's/href=/\nhref=/g' | \
        grep href=\" | sed 's/.*href="//g;s/".*//g' | \
        grep ${base_url} | \
        grep '/static/\|/media/' > /tmp/staticURLs;

    while read -a CONTENT; do
        status=$(curl $CONTENT -k -s -f -o /dev/null && echo "SUCCESS" || echo "ERROR")
        [ $status = "SUCCESS" ] && echo $CONTENT | grep / | cut -d/ -f4- >> ~/checkCdnContent.txt
    done < /tmp/staticURLs

    [ "$(${MAGENTO_BIN} config:show web/secure/base_url)" != ""  ] && protocol=https || protocol=http;
    cat > ~/checkCdnStatus.sh <<EOF
#!/bin/bash
while read -ru 4 CONTENT; do
    status=\$(curl \$1\$CONTENT -k -s -f -o /dev/null && echo "SUCCESS" || echo "ERROR")
    if [ \$status = "SUCCESS" ]
    then
        continue
    else
        exit
    fi
    done 4< ~/checkCdnContent.txt
    echo $(date -u) "Begin ${2} CDN set values" >>$LOG;
    ${MAGENTO_BIN} config:set web/unsecure/base_static_url ${protocol}://${cdn_url}/static/ &>> /var/log/run.log
    ${MAGENTO_BIN} config:set web/unsecure/base_media_url ${protocol}://${cdn_url}/media/ &>> /var/log/run.log
    ${MAGENTO_BIN} config:set web/secure/base_static_url ${protocol}://${cdn_url}/static/ &>> /var/log/run.log
    ${MAGENTO_BIN} config:set web/secure/base_media_url ${protocol}://${cdn_url}/media/ &>> /var/log/run.log
    ${MAGENTO_BIN} cache:flush &>> /var/log/run.log
    crontab -l | sed "/checkCdnStatus/d" | crontab -
    echo $(date -u) "End ${2} CDN set values" >>$LOG;
EOF
    chmod +x ~/checkCdnStatus.sh
    crontab -l | { cat; echo "* * * * * /bin/bash ~/checkCdnStatus.sh ${protocol}://${cdn_url}/"; } | crontab

}

case ${1} in
    install)
        install "$@"
        ;;

    litemage)
        litemage "$@"
        ;;

    domain)
        domain "$@"
        ;;

    baseUrl)
        baseUrl "$@"
        ;;

    varnish)
        varnish "$@"
        ;;

    ssl)
        ssl "$@"
        ;;

    edgeportCDN)
        edgeportCDN "$@"
        ;;

    cors)
        cors "$@"
        ;;

esac
