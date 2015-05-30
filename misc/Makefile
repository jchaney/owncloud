image_owncloud := jchaney/owncloud
BUILD_OPTIONS ?= --no-cache

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
		$(image_owncloud)
	# -e "TZ=Europe/Berlin" \

build:
	docker build $(BUILD_OPTIONS) --tag $(image_owncloud) ..

.PHONY: verify-gpg-public-keys
verify-gpg-public-keys: owncloud.asc

## Always renew
.PHONY: owncloud.asc
owncloud.asc:
	wget --output-document "$@" "https://owncloud.org/$@"
	git diff --exit-code -- owncloud.asc && echo 'OK' || echo 'Not OK'
