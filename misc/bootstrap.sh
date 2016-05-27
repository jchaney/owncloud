#!/bin/sh

touch /var/log/nginx/access.log
touch /var/log/nginx/error.log
touch /var/log/cron/owncloud.log

test -e /owncloud/config.php || cp /root/owncloud_config.php /owncloud/docker_image.config.php
test -e /owncloud/docker_image_owncloud.config.php || cp /root/docker_image_owncloud.config.php /owncloud/docker_image_owncloud.config.php
test -e /owncloud/3party_apps.conf || cp /root/3party_apps.conf /owncloud/

# Check whether a mysql database is linked
if [ -n "$MYSQL_PORT_3306_TCP_ADDR" ]
then
    # Set the auto configuration to the linked mysql database
    sed -i "s/conf_dbname/$MYSQL_ENV_MYSQL_DATABASE/g" /root/owncloud_autoconfig.php
    sed -i "s/conf_dbuser/$MYSQL_ENV_MYSQL_USER/g" /root/owncloud_autoconfig.php
    sed -i "s/conf_dbpassword/$MYSQL_ENV_MYSQL_PASSWORD/g" /root/owncloud_autoconfig.php
    sed -i "s/conf_dbhost/$MYSQL_PORT_3306_TCP_ADDR:$MYSQL_PORT_3306_TCP_PORT/g" /root/owncloud_autoconfig.php

    cp /root/owncloud_autoconfig.php /var/www/owncloud/config/autoconfig.php
fi

if [ -z "$SSL_CERT" ]
then
    echo "Copying nginx.conf without SSL support …"
    cp /root/nginx.conf /etc/nginx/nginx.conf
else
    echo "Copying nginx.conf with SSL support …"
    sed "s#-x-replace-cert-x-#$SSL_CERT#;s#-x-replace-key-x-#$SSL_KEY#;s#-x-server-name-x-#$OWNCLOUD_SERVERNAME#" /root/nginx_ssl.conf > /etc/nginx/nginx.conf
    if [ ! -e  /owncloud/dhparam.pem ]
    then
        echo "Generating prime for diffie-hellman key exchange …"
        openssl dhparam -out /owncloud/dhparam.pem 4096
        echo "Done generating DH prime"
    fi
fi

if [ "${OWNCLOUD_IN_ROOTPATH}" = "1" ]
then
    sed --in-place "s#-x-replace-oc-rootpath-#/var/www/owncloud/#" /etc/nginx/nginx.conf
else
    sed --in-place "s#-x-replace-oc-rootpath-#/var/www/#" /etc/nginx/nginx.conf
fi

cat << EOF | xargs chown --recursive www-data:www-data
/var/www/owncloud/data
/var/www/owncloud/assets
/var/www/owncloud/apps
/var/www/owncloud/apps_persistent
/var/www/owncloud/config/config.php
/owncloud
EOF

if ! occ  2>/dev/null | grep --quiet 'ownCloud is not installed'
then
    occ app:disable updater
    occ upgrade
fi

oc-install-3party-apps /owncloud/3party_apps.conf /var/www/owncloud/apps_persistent

echo "Starting server …"

tail --follow --retry /var/log/nginx/*.log /var/log/cron/owncloud.log &

/usr/sbin/cron -f &
/etc/init.d/php5-fpm start
/etc/init.d/nginx start
