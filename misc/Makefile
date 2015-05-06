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
