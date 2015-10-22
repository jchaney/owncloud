# docker-owncloud

Docker image for [ownCloud][] with security in mind.

The build instructions are tracked on [GitHub][this.project_github_url].
Automated builds are hosted on [Docker Hub][this.project_docker_hub_url].

## Why using this image

* It is directly based on Debian stable. No additional image layers which blow up the total image size and might by a security risk.
* Uses [nginx][] as webserver.
* [Hardened TLS](https://github.com/BetterCrypto/Applied-Crypto-Hardening/blob/master/src/configuration/Webservers/nginx/default-hsts) configuration.
* Local caching enabled by default (APCu).
  See https://owncloud.org/blog/making-owncloud-faster-through-caching/
* Installs the ownCloud tarball directly from https://owncloud.org/ and it [securely](https://github.com/jchaney/owncloud/pull/12) verifies the GPG signature.
* Makes installing of 3party apps easy and keeps them across updates.
* The [`occ`][occ] command can be used just by typing `docker exec -ti $owncloud_container_name occ`.

## Getting the image

You have two options to get the image:

1. Build it yourself with `make build`.
2. Download it via `docker pull jchaney/owncloud` ([automated build][this.project_docker_hub_url]).

## ownCloud up and running

Checkout the [Makefile][] for an example or just run `make owncloud` which will setup a ownCloud container instance (called "owncloud"). After that, just head over to [http://localhost/](http://localhost/) and give it a try. You can now create an admin account. For testing purposes you can use SQLite (but remember to use a real database in production).

## Running ownCloud in production

Setup a separate container running your database server and link it to the ownCloud container.
For running in production, you need to provide a TLS key and certificate. The
Makefile defaults to `/etc/ssl/private/ssl-cert-snakeoil.key` and
`/etc/ssl/certs/ssl-cert-snakeoil.pem`. Make sure those files exist or extend
the Makefile (you can include this Makefile and overwrite some variables in
your own Makefile). To generate self signed once you can run the following command:

```Shell
make-ssl-cert generate-default-snakeoil
```

To setup ownCloud with [MariaDB] as backend, just run:

```Shell
make owncloud-production
```

In the initial ownCloud setup, you need to supply the database user, password, database name and database host which you can look up via:

```Shell
make owncloud-mariadb-get-pw
```

That should be it :smile:

## Installing 3party apps

Just write the command(s) needed to install apps in a configuration file, mount it in the container and run

```Shell
oc-install-3party-apps /owncloud/path/to/your/config /var/www/owncloud/apps_persistent
```

in your container.
Checkout the [example configuration][3party_apps.conf] and the [script][oc-install-3party-apps] which does the work for details.

## Related projects

* [official docker repository for ownCloud](https://hub.docker.com/_/owncloud/)

  Uses Apache as webserver and is based on the [official Docker PHP image](https://hub.docker.com/_/php/).

* [l3iggs/owncloud](https://hub.docker.com/r/l3iggs/owncloud/)

  Uses Apache as webserver and is based on a self build LAMP stack based on Arch Linux.

## Maintainer

The current maintainer is [Robin `ypid` Schneider][ypid].

List of previous maintainers:

1. [Josh Chaney][jchaney]
2. [silvio][]

## Problems

* If you get "Command not found" for any of the programs used then install it (make sure you know what you are doing).

  > Your distribution packages: You should find missing dependencies from the errors yourself. It's _your_ machine, you're supposed to know it.

  Ref: https://bb.osmocom.org/trac/wiki/PreliminaryRequirements#Generalknowledge

## License

This project is distributed under [GNU Affero General Public License, Version 3][AGPLv3].

[ypid]: https://github.com/ypid
[silvio]: https://github.com/silvio
[jchaney]: https://github.com/jchaney

[Makefile]: /Makefile
[ownCloud]: https://owncloud.org/
[occ]: https://doc.owncloud.org/server/8.1/admin_manual/configuration_server/occ_command.html
[MariaDB]: https://mariadb.org/
[nginx]: https://en.wikipedia.org/wiki/Nginx

[3party_apps.conf]: https://github.com/jchaney/owncloud/blob/master/configs/3party_apps.conf
[oc-install-3party-apps]: https://github.com/jchaney/owncloud/blob/master/misc/oc-install-3party-apps
[AGPLv3]: https://github.com/jchaney/owncloud/blob/master/LICENSE
[this.project_docker_hub_url]: https://registry.hub.docker.com/u/jchaney/owncloud/
[this.project_github_url]: https://github.com/jchaney/owncloud
