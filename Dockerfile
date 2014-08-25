FROM		    ubuntu:14.04
MAINTAINER	Josh Chaney "josh@chaney.io"

ADD         owncloud-7.0.1.tar.bz2 /var/www/
ADD         bootstrap.sh /usr/bin/
ADD         nginx_ssl.conf /root/
ADD         nginx.conf /root/

RUN         apt-get update && \
            apt-get install -y php5-cli php5-gd php5-pgsql php5-sqlite php5-mysqlnd php5-curl php5-intl php5-mcrypt php5-ldap php5-gmp php5-apcu php5-imagick php5-fpm smbclient nginx && \
            mkdir /var/www/owncloud/data && \
            chown -R www-data:www-data /var/www/owncloud
            chmod +x /usr/bin/bootstrap.sh

ADD         php.ini /etc/php5/fpm/

EXPOSE      80
EXPOSE      443

ENTRYPOINT  ["bootstrap.sh"]
