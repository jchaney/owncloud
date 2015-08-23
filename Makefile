## For more examples of a Makefile based Docker container deployment see: https://github.com/ypid/docker-makefile

DOCKER_RUN_OPTIONS ?= --env "TZ=Europe/Berlin"

docker_owncloud_http_port ?= 80
docker_owncloud_https_port ?= 443
docker_owncloud_in_root_path ?= 1
docker_owncloud_permanent_storage ?= /tmp/owncloud
docker_owncloud_ssl_cert ?= /etc/ssl/certs/ssl-cert-snakeoil.pem
docker_owncloud_ssl_key ?= /etc/ssl/private/ssl-cert-snakeoil.key
docker_owncloud_servername ?= localhost

image_owncloud ?= jchaney/owncloud

.PHONY: start stop run build build-dev owncloud

start:
	docker start owncloud

stop:
	docker stop owncloud

run: owncloud

build:
	docker build --no-cache=true --tag $(image_owncloud) .

build-dev:
	docker build --no-cache=false --tag $(image_owncloud) .

owncloud:
	-@docker rm --force "$@"
	docker run --detach \
		--name "$@" \
		--volume $(docker_owncloud_permanent_storage)/data:/var/www/owncloud/data \
		--publish $(docker_owncloud_http_port):80 \
		--publish $(docker_owncloud_https_port):443 \
		--env OWNCLOUD_IN_ROOTPATH=$(docker_owncloud_in_root_path) \
		$(DOCKER_RUN_OPTIONS) \
		$(image_owncloud)

# make-ssl-cert generate-default-snakeoil
owncloud-ssl:
	-@docker rm --force "$@"
	docker run --detach \
		--name "$@" \
		--volume $(docker_owncloud_permanent_storage)/data:/var/www/owncloud/data \
		--publish $(docker_owncloud_http_port):80 \
		--publish $(docker_owncloud_https_port):443 \
		--volume $(docker_owncloud_ssl_cert):$(docker_owncloud_ssl_cert):ro \
		--volume $(docker_owncloud_ssl_key):$(docker_owncloud_ssl_key):ro \
		--env OWNCLOUD_IN_ROOTPATH=$(docker_owncloud_in_root_path) \
		--env OWNCLOUD_SERVERNAME=$(docker_owncloud_servername) \
		--env SSL_CERT=$(docker_owncloud_ssl_cert) \
		--env SSL_KEY=$(docker_owncloud_ssl_key) \
		$(DOCKER_RUN_OPTIONS) \
		$(image_owncloud)

owncloud-dev:
	-@docker rm --force "$@"
	docker run --detach \
		--name "$@" \
		--volume $(docker_owncloud_permanent_storage)-dev/data:/var/www/owncloud/data \
		--volume $(docker_owncloud_permanent_storage)-dev/additional_apps:/var/www/owncloud/apps_persistent \
		--publish $(docker_owncloud_http_port):80 \
		--publish $(docker_owncloud_https_port):443 \
		--env OWNCLOUD_IN_ROOTPATH=$(docker_owncloud_in_root_path) \
		$(DOCKER_RUN_OPTIONS) \
		$(image_owncloud)

		# --volume $(docker_owncloud_permanent_storage)-dev/config:/owncloud \
