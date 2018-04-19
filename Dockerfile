FROM debian:jessie
MAINTAINER  Robin Schneider <ypid@riseup.net>
# MAINTAINER silvio <silvio@port1024.net>
# MAINTAINER Josh Chaney <josh@chaney.io>

RUN DEBIAN_FRONTEND=noninteractive ;\
    apt-get update && \
    apt-get install --assume-yes \
        bzip2 \
        cron \
        nginx \
        openssl \
        php-apc \
        php5-apcu \
        php5-cli \
        php5-curl \
        php5-fpm \
        php5-gd \
        php5-gmp \
        php5-imagick \
        php5-intl \
        php5-ldap \
        php5-mcrypt \
        php5-mysqlnd \
        php5-pgsql \
        php5-sqlite \
        smbclient \
        sudo \
        wget

## Check latest version: https://github.com/owncloud/core/wiki/Maintenance-and-Release-Schedule
ENV OWNCLOUD_VERSION="10.0.7" \
    OWNCLOUD_IN_ROOTPATH="0" \
    OWNCLOUD_SERVERNAME="localhost"

LABEL com.github.jchaney.owncloud.version="$OWNCLOUD_VERSION" \
      com.github.jchaney.owncloud.license="AGPL-3.0" \
      com.github.jchaney.owncloud.url="https://github.com/jchaney/owncloud"

RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys E3036906AD9F30807351FAC32D5D5E97F6978A26

RUN wget --no-verbose --output-document /tmp/oc.tar.bz2 https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2 && \
    wget --no-verbose --output-document /tmp/oc.tar.bz2.asc https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2.asc
RUN mkdir --parent /var/www/owncloud/apps_persistent /owncloud /var/log/cron && \
    gpg --verify /tmp/oc.tar.bz2.asc && \
    tar --no-same-owner --directory /var/www/ --extract --file /tmp/oc.tar.bz2 && \
    ln --symbolic --force /owncloud/config.php /var/www/owncloud/config/config.php && \
    ln --symbolic --force /owncloud/docker_image_owncloud.config.php /var/www/owncloud/config/docker_image_owncloud.config.php && \
    rm /tmp/oc.tar.bz2 /tmp/oc.tar.bz2.asc

ADD misc/bootstrap.sh misc/occ misc/oc-install-3party-apps /usr/local/bin/
ADD configs/3party_apps.conf configs/nginx_ssl.conf configs/nginx.conf configs/docker_image_owncloud.config.php configs/owncloud_autoconfig.php /root/

## Fixed warning in admin panel getenv('PATH') == '' for ownCloud 8.1.
RUN echo 'env[PATH] = /usr/local/bin:/usr/bin:/bin' >> /etc/php5/fpm/pool.d/www.conf

ADD configs/cron.conf /etc/oc-cron.conf
RUN crontab /etc/oc-cron.conf

EXPOSE 80 443

ENTRYPOINT ["bootstrap.sh"]
