#!/bin/sh

touch /var/log/nginx/access.log
touch /var/log/nginx/error.log
touch /var/log/cron/owncloud.log

if [ -z "$SSL_CERT" ]; then
    echo "Copying nginx.conf without SSL support …"
    cp /root/nginx.conf /etc/nginx/nginx.conf
else
    echo "Copying nginx.conf with SSL support …"
    sed "s#-x-replace-cert-x-#$SSL_CERT#;s#-x-replace-key-x-#$SSL_KEY#;s#-x-server-name-x-#$OWNCLOUD_SERVERNAME#" /root/nginx_ssl.conf > /etc/nginx/nginx.conf
fi

if [ "${OWNCLOUD_IN_ROOTPATH}" = "1" ]; then
    sed -i "s#-x-replace-oc-rootpath-#/var/www/owncloud/#" /etc/nginx/nginx.conf
else
    sed -i "s#-x-replace-oc-rootpath-#/var/www/#" /etc/nginx/nginx.conf
fi

chown -R www-data:www-data /var/www/owncloud /owncloud
echo "Starting server …"

tail -F /var/log/nginx/*.log /var/log/cron/owncloud.log &

/usr/sbin/cron -f &
/etc/init.d/php5-fpm start
/etc/init.d/nginx start
