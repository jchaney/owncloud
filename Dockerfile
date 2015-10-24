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

## Check latest version: https://owncloud.org/install/#instructions-server
ENV OWNCLOUD_VERSION 8.1.3
ENV OWNCLOUD_IN_ROOTPATH 0
ENV OWNCLOUD_SERVERNAME localhost

LABEL com.github.jchaney.owncloud.version="$OWNCLOUD_VERSION" \
      com.github.jchaney.owncloud.license="AGPL-3.0" \
      com.github.jchaney.owncloud.url="https://github.com/jchaney/owncloud"

ADD misc/bootstrap.sh misc/occ misc/oc-install-3party-apps /usr/local/bin/
ADD configs/3party_apps.conf configs/owncloud_config.php configs/nginx_ssl.conf configs/nginx.conf /root/

## Could be used: https://github.com/docker-library/owncloud/blob/master/8.1/Dockerfile
## RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys E3036906AD9F30807351FAC32D5D5E97F6978A26

## For testing:
# COPY owncloud-${OWNCLOUD_VERSION}.tar.bz2 /tmp/oc.tar.bz2

ADD https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2 /tmp/oc.tar.bz2
ADD https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2.asc /tmp/oc.tar.bz2.asc
ADD misc/owncloud.asc /tmp/owncloud.asc
RUN mkdir --parent /var/www/owncloud/apps_persistent /owncloud /var/log/cron && \
    gpg --import /tmp/owncloud.asc && \
    gpg --verify /tmp/oc.tar.bz2.asc && \
    tar -C /var/www/ -xf /tmp/oc.tar.bz2 && \
    chown -R www-data:www-data /var/www/owncloud && \
    ln --symbolic --force /owncloud/config.php /var/www/owncloud/config/config.php && \
    rm /tmp/oc.tar.bz2 /tmp/oc.tar.bz2.asc /tmp/owncloud.asc

## Fixes: PHP is configured to populate raw post data. Since PHP 5.6 this will lead to PHP throwing notices for perfectly valid code. #19
RUN echo 'always_populate_raw_post_data = -1' | tee --append /etc/php5/cli/php.ini /etc/php5/fpm/php.ini

## Allow usage of `sudo -u www-data php /var/www/owncloud/occ` with APC.
## FIXME: Temporally: https://github.com/owncloud/core/issues/17329
RUN echo 'apc.enable_cli = 1' >> /etc/php5/cli/php.ini

## Fixed warning in admin panel getenv('PATH') == '' for ownCloud 8.1.
RUN echo 'env[PATH] = /usr/local/bin:/usr/bin:/bin' >> /etc/php5/fpm/pool.d/www.conf

ADD configs/cron.conf /etc/oc-cron.conf
RUN crontab /etc/oc-cron.conf

EXPOSE 80
EXPOSE 443

ENTRYPOINT  ["bootstrap.sh"]
