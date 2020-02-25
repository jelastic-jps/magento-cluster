#!/bin/bash -e

purge=false;
pgcache=false;
objectcache=false;
edgeportCDN=false;
wpmu=false;
DOMAIN=false;

SERVER_WEBROOT=/var/www/webroot/ROOT

ARGUMENT_LIST=(
    "purge"
    "pgcache"
    "objectcache"
    "edgeportCDN"
    "REDIS_HOST"
    "REDIS_PASS"
    "CDN_URL"
    "CDN_ORI"
    "MODE"
    "DOMAIN"

)

MG="php ${SERVER_WEBROOT}/bin/magento"

# read arguments
opts=$(getopt \
    --longoptions "$(printf "%s:," "${ARGUMENT_LIST[@]}")" \
    --name "$(basename "$0")" \
    --options "" \
    -- "$@"
)
eval set --$opts

while [[ $# -gt 0 ]]; do
    case "$1" in
        --purge)
            purge=$2
            shift 2
            ;;

        --perfomance)
            perfomance=$2
            shift 2
            ;;

        --PERF_PROFILE)
            PERF_PROFILE=$2
            shift 2
            ;;

        --edgeportCDN)
            edgeportCDN=$2
            shift 2
            ;;

        --REDIS_HOST)
            REDIS_HOST=$2
            shift 2
            ;;

        --REDIS_PASS)
            REDIS_PASS=$2
            shift 2
            ;;

        --CDN_URL)
            CDN_URL=$2
            shift 2
            ;;

        --CDN_ORI)
            CDN_ORI=$2
            shift 2
            ;;

        --DOMAIN)
            DOMAIN=$2
            shift 2
            ;;

        *)
            break
            ;;
    esac
done

lOG="/var/log/run.log"

COMPUTE_TYPE=$(grep "COMPUTE_TYPE=" /etc/jelastic/metainf.conf | cut -d"=" -f2)

cd ${SERVER_WEBROOT};

function checkCdnStatus () {
cat > ~/bin/checkCdnStatus.sh <<EOF
#!/bin/bash
while read -ru 4 CONTENT; do
  status=\$(curl \$1\$CONTENT -k -s -f -o /dev/null && echo "SUCCESS" || echo "ERROR")
    if [ \$status = "SUCCESS" ]
    then
      continue
    else
      exit
    fi
done 4< ~/bin/checkCdnContent.txt
cd ${SERVER_WEBROOT}
${MG} cache:flush &>> /var/log/run.log &>> /var/log/run.log
crontab -l | sed "/checkCdnStatus/d" | crontab -
EOF
chmod +x ~/bin/checkCdnStatus.sh
PROTOCOL=$(${MG} config:show web/unsecure/base_url | cut -d':' -f1)
crontab -l | { cat; echo "* * * * * /bin/bash ~/bin/checkCdnStatus.sh ${PROTOCOL}://${CDN_URL}/"; } | crontab
}


if [ $perfomance == 'true' ] ; then
   ${MG} setup:performance:generate-fixtures -s ${SERVER_WEBROOT}/setup/performance-toolkit/profiles/ce/${PERF_PROFILE} &>> /var/log/run.log
   ${MG} indexer:reindex &>> /var/log/run.log
fi

if [ $edgeportCDN == 'true' ] ; then
    checkCdnStatus
    PROTOCOL=$(${MG} config:show web/unsecure/base_url | cut -d':' -f1)
    ${MG} config:set web/unsecure/base_static_url ${PROTOCOL}://${CDN_URL}/pub/static/ &>> /var/log/run.log
    ${MG} config:set web/unsecure/base_media_url ${PROTOCOL}://${CDN_URL}/pub/media/ &>> /var/log/run.log
    ${MG} config:set web/secure/base_static_url ${PROTOCOL}://${CDN_URL}/pub/static/ &>> /var/log/run.log
    ${MG} config:set web/secure/base_media_url ${PROTOCOL}://${CDN_URL}/pub/media/ &>> /var/log/run.log

fi

if [ $DOMAIN != 'false' ] ; then
    ${MG} config:set web/unsecure/base_url ${DOMAIN} &>> /var/log/run.log
    ${MG} config:set web/secure/base_url ${DOMAIN} &>> /var/log/run.log
    ${MG} config:set web/secure/use_in_adminhtml 1 &>> /var/log/run.log
    ${MG} indexer:reindex &>> /var/log/run.log
fi
