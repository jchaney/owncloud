# docker-owncloud

Docker image for [ownCloud][] with security in mind.

This image is also on [Docker Hub][].

## Why using this image

* It is directly based on Debian stable. No additional image layers which blow up the total image size and might by a security risk.
* Uses [nginx][] as webserver.
* [Hardened TLS](https://github.com/BetterCrypto/Applied-Crypto-Hardening/blob/master/src/configuration/Webservers/nginx/default-hsts) configuration.
* Local caching enabled by default (APCu).
  See https://owncloud.org/blog/making-owncloud-faster-through-caching/
* Installs the ownCloud tarball directly from https://owncloud.org/ and it [securely](https://github.com/jchaney/owncloud/pull/12) verifies the GPG signature.
* Makes installing of 3party apps easy and keeps them across updates.

## Getting the image

You have two options to get the image:

1. Build it yourself with `make build`.
2. Download it via `docker pull jchaney/owncloud` ([automated build][Docker Hub])

## ownCloud up and running

Checkout the [Makefile][] for an example or just run `make owncloud` which will setup a ownCloud container instance (called "owncloud"). After that, just head over to [http://localhost/](http://localhost/) and give it a try. You can now create an admin account. For testing purposes you can use SQLite (but remember to use a real database in production).

## Running ownCloud in production

Setup a separat container running your database server and link it to the ownCloud container.
To setup ownCloud with [MariaDB] as backend, just run:

```Shell
make owncloud-production
```

In the initial ownCloud setup, you need to supply the database password which you can look up via (`MYSQL_PASSWORD`):

```Shell
docker exec owncloud-mariadb env
```

The hostname of your database is "db".

That should be it :smile:

## Installing 3party apps

Just write the command(s) needed to install apps in configuration file, mount it in the container and run

```Shell
oc-install-3party-apps /owncloud/path/to/your/config /var/www/owncloud/apps_persistent
```

in your container.
Checkout the [example configuration][3party_apps.conf] and the [script][oc-install-3party-apps] which does the work for details.

## Maintainer

The current maintainer is [Robin `ypid` Schneider][ypid].

List of previous maintainers:

1. [Josh Chaney][jchaney]
2. [silvio][]

## License

This project is distributed under [GNU Affero General Public License, Version 3][AGPLv3].

[ypid]: https://github.com/ypid
[silvio]: https://github.com/silvio
[jchaney]: https://github.com/jchaney

[Makefile]: /Makefile
[ownCloud]: https://owncloud.org/
[MariaDB]: https://mariadb.org/
[Docker Hub]: https://registry.hub.docker.com/u/jchaney/owncloud/
[nginx]: http://nginx.org/

[3party_apps.conf]: https://github.com/jchaney/owncloud/blob/master/configs/3party_apps.conf
[oc-install-3party-apps]: https://github.com/jchaney/owncloud/blob/master/misc/oc-install-3party-apps
[AGPLv3]: https://github.com/jchaney/owncloud/blob/master/LICENSE
