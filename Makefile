image_owncloud := jchaney/owncloud

.PHONY: start stop run build owncloud

start:
	docker start owncloud

stop:
	docker stop owncloud

run: owncloud

owncloud:
	-@docker rm -f "$@"
	docker run -d \
		--name "$@" \
		-e "TZ=Europe/Berlin" \
		$(image_owncloud)

build:
	docker build --no-cache --tag $(image_owncloud) .
	# docker build --tag $(image_owncloud) .

.PHONY: verify-gpg-public-keys
verify-gpg-public-keys: owncloud.asc

## Always renew
.PHONY: owncloud.asc
owncloud.asc:
	wget --output-document "$@" https://owncloud.org/owncloud.asc
