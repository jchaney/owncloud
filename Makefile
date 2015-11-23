## For more examples of a Makefile based Docker container deployment see: https://github.com/ypid/docker-makefile

DOCKER_RUN_OPTIONS ?= --env "TZ=Europe/Berlin"

docker_owncloud_http_port    ?= 80
docker_owncloud_https_port   ?= 443
docker_owncloud_in_root_path ?= 1
docker_owncloud_permanent_storage ?= /tmp/owncloud
docker_owncloud_ssl_cert ?= /etc/ssl/certs/ssl-cert-snakeoil.pem
docker_owncloud_ssl_key  ?= /etc/ssl/private/ssl-cert-snakeoil.key
docker_owncloud_servername ?= localhost

docker_owncloud_mariadb_user ?= owncloud-production

image_owncloud ?= jchaney/owncloud
image_mariadb  ?= mariadb

.PHONY: default start stop run build build-dev owncloud owncloud-https owncloud-mariadb owncloud-mariadb-get-pw owncloud-mariadb-cli owncloud-production owncloud-dev rm-containers rm-container-tmp-data

default:
	@echo 'See Makefile and README.md'

start:
	docker start owncloud

stop:
	docker stop owncloud owncloud-https owncloud-mariadb owncloud-production owncloud-dev

run: owncloud

rm-containers:
	docker rm --force owncloud owncloud-https owncloud-mariadb owncloud-production owncloud-dev

rm-container-tmp-data:
	rm -rf "$(docker_owncloud_permanent_storage)" "$(docker_owncloud_permanent_storage)-dev" || echo "You need root permissions for this"

build:
	docker build --no-cache=true --tag $(image_owncloud) .

build-dev:
	docker build --no-cache=false --tag $(image_owncloud) .

owncloud:
	-@docker rm --force "$@"
	docker run --detach \
		--name "$@" \
		$(DOCKER_RUN_OPTIONS) \
		--volume "$(docker_owncloud_permanent_storage)/data:/var/www/owncloud/data" \
		--volume "$(docker_owncloud_permanent_storage)/additional_apps:/var/www/owncloud/apps_persistent" \
		--volume "$(docker_owncloud_permanent_storage)/config:/owncloud" \
		--publish $(docker_owncloud_http_port):80 \
		--publish $(docker_owncloud_https_port):443 \
		--env "OWNCLOUD_IN_ROOTPATH=$(docker_owncloud_in_root_path)" \
		$(image_owncloud)

# make-ssl-cert generate-default-snakeoil
owncloud-https:
	-@docker rm --force "$@"
	docker run --detach \
		--name "$@" \
		$(DOCKER_RUN_OPTIONS) \
		--publish $(docker_owncloud_http_port):80 \
		--publish $(docker_owncloud_https_port):443 \
		--volume "$(docker_owncloud_permanent_storage)/data:/var/www/owncloud/data" \
		--volume "$(docker_owncloud_permanent_storage)/additional_apps:/var/www/owncloud/apps_persistent" \
		--volume "$(docker_owncloud_permanent_storage)/config:/owncloud" \
		--volume "$(docker_owncloud_ssl_cert):$(docker_owncloud_ssl_cert):ro" \
		--volume "$(docker_owncloud_ssl_key):$(docker_owncloud_ssl_key):ro" \
		--env "OWNCLOUD_IN_ROOTPATH=$(docker_owncloud_in_root_path)" \
		--env "OWNCLOUD_SERVERNAME=$(docker_owncloud_servername)" \
		--env "SSL_CERT=$(docker_owncloud_ssl_cert)" \
		--env "SSL_KEY=$(docker_owncloud_ssl_key)" \
		$(image_owncloud)

owncloud-production: owncloud-mariadb
	-@docker rm --force "$@"
	docker run --detach \
		--name "$@" \
		$(DOCKER_RUN_OPTIONS) \
		--link owncloud-mariadb:db \
		--publish $(docker_owncloud_http_port):80 \
		--publish $(docker_owncloud_https_port):443 \
		--volume "$(docker_owncloud_permanent_storage)/data:/var/www/owncloud/data" \
		--volume "$(docker_owncloud_permanent_storage)/additional_apps:/var/www/owncloud/apps_persistent" \
		--volume "$(docker_owncloud_permanent_storage)/config:/owncloud" \
		--volume "$(docker_owncloud_ssl_cert):$(docker_owncloud_ssl_cert):ro" \
		--volume "$(docker_owncloud_ssl_key):$(docker_owncloud_ssl_key):ro" \
		--env "OWNCLOUD_IN_ROOTPATH=$(docker_owncloud_in_root_path)" \
		--env "OWNCLOUD_SERVERNAME=$(docker_owncloud_servername)" \
		--env "SSL_CERT=$(docker_owncloud_ssl_cert)" \
		--env "SSL_KEY=$(docker_owncloud_ssl_key)" \
		--env "DB_ENV_MYSQL_USER=overwrite" \
		--env "DB_ENV_MYSQL_PASSWORD=overwrite" \
		--env "DB_ENV_MYSQL_DATABASE=overwrite" \
		--env "DB_ENV_MYSQL_ROOT_PASSWORD=overwrite" \
		$(image_owncloud)

owncloud-mariadb:
	-@docker rm --force "$@"
	docker run --detach \
		--name "$@" \
		$(DOCKER_RUN_OPTIONS) \
		--volume $(docker_owncloud_permanent_storage)/db:/var/lib/mysql \
		--env "MYSQL_ROOT_PASSWORD=$(shell pwgen --secure 40 1)" \
		--env "MYSQL_USER=$(docker_owncloud_mariadb_user)" \
		--env "MYSQL_DATABASE=$(docker_owncloud_mariadb_user)" \
		--env "MYSQL_PASSWORD=$(shell pwgen --secure 40 1)" \
		$(image_mariadb)

owncloud-mariadb-get-pw:
	docker exec owncloud-mariadb \
		sh -c '(env | egrep "^MYSQL_USER="; \
				env | egrep "^MYSQL_(DATABASE|PASSWORD)="; \
			) | sed "s/=/: /"; \
			echo "Database host: db"'

owncloud-mariadb-cli:
	docker run --rm --interactive --tty \
		--name "$@" \
		$(DOCKER_RUN_OPTIONS) \
		--link owncloud-mariadb:mysql \
		$(image_mariadb) \
		sh -c 'mysql -h"$$MYSQL_PORT_3306_TCP_ADDR" -P"$$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'

owncloud-dev:
	-@docker rm --force "$@"
	docker run --detach \
		--name "$@" \
		$(DOCKER_RUN_OPTIONS) \
		--volume "$(docker_owncloud_permanent_storage)-dev/data:/var/www/owncloud/data" \
		--volume "$(docker_owncloud_permanent_storage)-dev/additional_apps:/var/www/owncloud/apps_persistent" \
		--volume "$(docker_owncloud_permanent_storage)-dev/config:/owncloud" \
		--publish $(docker_owncloud_http_port):80 \
		--publish ""$(docker_owncloud_https_port):443 \
		--volume "$(PWD)/debugging/phpinfo.php:/var/www/owncloud/phpinfo.php" \
		--env "OWNCLOUD_IN_ROOTPATH=$(docker_owncloud_in_root_path)" \
		$(image_owncloud)
		# --volume "$(PWD)/configs/php_uploads.ini:/etc/php5/fpm/conf.d/uploads.ini" \
		# --volume "$(PWD)/configs/htaccess_uploads:/var/www/owncloud/.htaccess_upload" \
