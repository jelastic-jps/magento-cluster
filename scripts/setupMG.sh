#!/bin/bash -e

purge=false;
litemage=false;
pgcache=false;
objectcache=false;
edgeportCDN=false;
DOMAIN=false;
perfomance=false;

SERVER_WEBROOT=/var/www/webroot/ROOT
GITHUB_LITEMAGE_SOURCE=litespeedtech/magento2-LiteSpeed_LiteMage

ARGUMENT_LIST=(
    "purge"
    "litemage"
    "pgcache"
    "objectcache"
    "perfomance"
    "edgeportCDN"
    "PERF_PROFILE"
    "REDIS_HOST"
    "REDIS_PASS"
    "CDN_URL"
    "CDN_ORI"
    "MODE"
    "DOMAIN"

)

MG="php ${SERVER_WEBROOT}/bin/magento"
WGET=`which wget`
SED=`which sed`
RSYNC=`which rsync`
TAR=`which tar`
COMPOSER=`which composer`

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

        --litemage)
            litemage=$2
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

function generateCdnContent () {
  [ -f ~/checkCdnContent.txt ] && rm -f ~/checkCdnContent.txt
  base_url=$(${MG} config:show web/unsecure/base_url)
  wget ${base_url} -O /tmp/index.html
  cat /tmp/index.html | \
    sed 's/href=/\nhref=/g' | \
    grep href=\" | sed 's/.*href="//g;s/".*//g' | \
    grep ${base_url} | \
    grep 'pub/static\|pub/media' > /tmp/fullListUrls

  while read -a CONTENT; do
    status=$(curl $CONTENT -k -s -f -o /dev/null && echo "SUCCESS" || echo "ERROR")
    [ $status = "SUCCESS" ] && echo $CONTENT | grep / | cut -d/ -f4- >> ~/checkCdnContent.txt
  done < /tmp/fullListUrl
}

function checkCdnStatus () {
PROTOCOL=$(${MG} config:show web/unsecure/base_url | cut -d':' -f1)
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
cd ${SERVER_WEBROOT}
${MG} config:set web/unsecure/base_static_url ${PROTOCOL}://${CDN_URL}/pub/static/ &>> /var/log/run.log
${MG} config:set web/unsecure/base_media_url ${PROTOCOL}://${CDN_URL}/pub/media/ &>> /var/log/run.log
${MG} config:set web/secure/base_static_url ${PROTOCOL}://${CDN_URL}/pub/static/ &>> /var/log/run.log
${MG} config:set web/secure/base_media_url ${PROTOCOL}://${CDN_URL}/pub/media/ &>> /var/log/run.log
${MG} cache:flush &>> /var/log/run.log
crontab -l | sed "/checkCdnStatus/d" | crontab -
EOF
chmod +x ~/checkCdnStatus.sh
crontab -l | { cat; echo "* * * * * /bin/bash ~/checkCdnStatus.sh ${PROTOCOL}://${CDN_URL}/"; } | crontab
}

if [ $litemage == 'true' ] ; then
  VERSION=$(curl --silent "https://api.github.com/repos/${GITHUB_LITEMAGE_SOURCE}/releases" | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/' | sort -r | head -n 1);
  SHORT_VERSION=$(echo ${VERSION} | sed 's/v//');
  $WGET https://github.com/${GITHUB_LITEMAGE_SOURCE}/archive/${VERSION}.tar.gz -O /tmp/${VERSION}.tgz;
  $TAR -C "/tmp" -xpzf "/tmp/${VERSION}.tgz";
  [ -d ${SERVER_WEBROOT}/app/code/Litespeed/Litemage ] || mkdir -p ${SERVER_WEBROOT}/app/code/Litespeed/Litemage;
  $RSYNC -au --remove-source-files /tmp/magento2-LiteSpeed_LiteMage-${SHORT_VERSION}/ ${SERVER_WEBROOT}/app/code/Litespeed/Litemage/;
  ${MG} module:enable Litespeed_Litemage &>> /var/log/run.log;
  ${MG} setup:upgrade &>> /var/log/run.log;
  ${MG} config:set system/full_page_cache/caching_application LITEMAGE &>> /var/log/run.log;
fi


if [ $perfomance == 'true' ] ; then
   ${MG} setup:performance:generate-fixtures -s ${SERVER_WEBROOT}/setup/performance-toolkit/profiles/ce/${PERF_PROFILE} &>> /var/log/run.log
fi

if [ $edgeportCDN == 'true' ] ; then
    generateCdnContent
    checkCdnStatus
fi

if [ $DOMAIN != 'false' ] ; then
    ${MG} config:set web/unsecure/base_url ${DOMAIN} &>> /var/log/run.log
    ${MG} config:set web/secure/base_url ${DOMAIN} &>> /var/log/run.log
    ${MG} config:set web/secure/use_in_adminhtml 1 &>> /var/log/run.log
    ${MG} indexer:reindex &>> /var/log/run.log
fi
