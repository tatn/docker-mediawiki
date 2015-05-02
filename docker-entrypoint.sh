#!/bin/bash
set -eu

: ${MEDIAWIKI_DB_TYPE:=mysql}
: ${MEDIAWIKI_DB_SERVER:=${MYSQL_PORT_3306_TCP#tcp://}}
: ${MEDIAWIKI_DB_NAME:=mediawiki}
: ${MEDIAWIKI_DB_USER:=root}

if [ "$MEDIAWIKI_DB_USER" = 'root' ]; then
        : ${MEDIAWIKI_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
fi

rsync -a -q -x /usr/src/mediawiki/ /var/www/html
rsync -a -u -q -x /usr/local/apache2/ /etc/apache2

if [ -e /var/www/html/LocalSettings.php ]; then

        set_config() {
                key="$1"
                value="$2"
                sed -ri "s/($key\s*=\s*)(['\"])[^'\"]+(['\"])/\1\2$value\3/g" /var/www/html/LocalSettings.php
        }

        set_config 'wgDBtype' "$MEDIAWIKI_DB_TYPE"
        set_config 'wgDBserver' "$MEDIAWIKI_DB_SERVER"
        set_config 'wgDBname' "$MEDIAWIKI_DB_NAME"
        set_config 'wgDBuser' "$MEDIAWIKI_DB_USER"
        set_config 'wgDBpassword' "$MEDIAWIKI_DB_PASSWORD"
fi

export MEDIAWIKI_DB_TYPE MEDIAWIKI_DB_SERVER MEDIAWIKI_DB_NAME MEDIAWIKI_DB_USER MEDIAWIKI_DB_PASSWORD

exec "$@"

