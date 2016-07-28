#!/bin/bash
MEMECACHE_ARRD_1=$1;
MEMECACHE_ARRD_2=$2;

rm -rf /var/www/webroot/ROOT/var/*;

/etc/init.d/nginx restart; /etc/init.d/php-fpm restart;
