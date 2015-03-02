FROM		    ubuntu:14.04
MAINTAINER	Josh Chaney "josh@chaney.io"

ADD         bootstrap.sh /usr/bin/
ADD         nginx_ssl.conf /root/
ADD         nginx.conf /root/

ENV         DEBIAN_FRONTEND noninteractive
RUN         dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

RUN         apt-get update && \
            apt-get install -y php5-cli php5-gd php5-pgsql php5-sqlite php5-mysqlnd php5-curl php5-intl php5-mcrypt php5-ldap php5-gmp php5-apcu php5-imagick php5-fpm smbclient nginx wget

ADD         https://download.owncloud.org/community/owncloud-8.0.0.tar.bz2 /tmp/oc.tar.bz2
RUN         mkdir -p /var/www/owncloud /owncloud /var/log/cron && \
            tar -C /var/www/ -xvf /tmp/oc.tar.bz2 && \
            chown -R www-data:www-data /var/www/owncloud && \
            rm -rf /var/www/owncloud/config && ln -sf /owncloud /var/www/owncloud/config && \
            chmod +x /usr/bin/bootstrap.sh && \
            rm /tmp/oc.tar.bz2

ADD         php.ini /etc/php5/fpm/
ADD         cron.conf /etc/oc-cron.conf
RUN         crontab /etc/oc-cron.conf

ADD         extensions.sh extensions.conf /var/www/owncloud/apps/
RUN         chmod a+x /var/www/owncloud/apps/extensions.sh ; \
            /var/www/owncloud/apps/extensions.sh /var/www/owncloud/apps/extensions.conf /var/www/owncloud/apps ; \
            rm /var/www/owncloud/apps/extensions.sh /var/www/owncloud/apps/extensions.conf

EXPOSE      80
EXPOSE      443

ENTRYPOINT  ["bootstrap.sh"]
