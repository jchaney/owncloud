# docker-owncloud

[![Docker Stars](https://img.shields.io/docker/stars/jchaney/owncloud.svg)][this.project_docker_hub_url]
[![Docker Pulls](https://img.shields.io/docker/pulls/jchaney/owncloud.svg)][this.project_docker_hub_url]
[![ImageLayers Size](https://img.shields.io/imagelayers/image-size/jchaney/owncloud/latest.svg)][this.project_docker_hub_url]
[![ImageLayers Layers](https://img.shields.io/imagelayers/layers/jchaney/owncloud/latest.svg)][this.project_docker_hub_url]

Docker image for [ownCloud][] with security in mind.

The build instructions are tracked on [GitHub][this.project_github_url].
[Automated builds][] are hosted on [Docker Hub][this.project_docker_hub_url].

## Why using this image

* It is directly based on Debian stable. No additional image layers which blow up the total image size and might by a security risk.
* Uses [nginx][] as webserver.
* [Hardened TLS](https://github.com/BetterCrypto/Applied-Crypto-Hardening/blob/master/src/configuration/Webservers/nginx/default-hsts) configuration.
* Generates unique Diffie Hellman parameters to mitigate precomputation based attacks on common parameters. Refs: [Guide to Deploying Diffie-Hellman for TLS](https://weakdh.org/sysadmin.html).
* Local caching enabled by default (APCu).
  See https://owncloud.org/blog/making-owncloud-faster-through-caching/
* Installs the ownCloud tarball directly from https://owncloud.org/ and it [securely](https://github.com/jchaney/owncloud/pull/12) verifies the GPG signature.
* Makes installing of 3party apps easy and keeps them across updates.
* The [`occ`][occ] command can be used just by typing `docker exec -ti $owncloud_container_name occ`.
* ownCloud can only be updated by redeploying the container. No update via the web interface is possible. The ownCloud installation is fully contained in the container and not made persistent. This allows to make the ownCloud installation write protected for the Webserver and PHP which run as `www-data`.
* Automated database update on ownCloud update during the startup of a redeployed/updated container.

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

## Update your container and ownCloud

It is recommended to rebuild/pull this image on a regular basis and redeploy your ownCloud container(s) to get the latest security fixes.
Note that ownCloud version jumps are uploaded to the `latest` tag of this image once they are tested. You might want to watch this repository to see when this happens.

Once the ownCloud image is up-to-date, just run:

```Shell
make owncloud-production
```

to update your container. ownCloud usually requires a database update when the version of ownCloud is bumped. This process [has been automated](/misc/bootstrap.sh) for this Docker image but remember that you are still in charge of making backups/snapshots prior to updates!

## Installing 3party apps

Just write the command(s) needed to install apps in a configuration file and make sure it is present as `/owncloud/3party_apps.conf` in your container.

Checkout the [example configuration][3party_apps.conf] and the [install script][oc-install-3party-apps] for details.

## docker-compose support

You can also run this image with `docker-compose`. First you need to declare all env variables since `docker-compose` does not support (yet) default variables.

```Shell
# Where to store data and database ?
export docker_owncloud_permanent_storage="~/owncloud_data"

# SSL Certificates to use.
export docker_owncloud_ssl_cert="../certs/cloud.cert"
export docker_owncloud_ssl_key="../certs/cloud.key"

# Servername
export docker_owncloud_servername="localhost"

export docker_owncloud_http_port="80"
export docker_owncloud_https_port="443"
export docker_owncloud_in_root_path="1"

export docker_owncloud_mariadb_root_password=$(pwgen --secure 40 1)
export docker_owncloud_mariadb_user_password=$(pwgen --secure 40 1)

export image_owncloud="jchaney/owncloud"
export image_mariadb="mysql"

```

Then:

```Shell
docker-compose up
```

That's all !

## Related projects

* [official docker repository for ownCloud](https://hub.docker.com/_/owncloud/)

  Uses Apache as webserver and is based on the [official Docker PHP image](https://hub.docker.com/_/php/).

* [l3iggs/owncloud](https://hub.docker.com/r/l3iggs/owncloud/)

  Uses Apache as webserver and is based on a self build LAMP stack based on Arch Linux.

* [Ansible role to install and manage ownCloud instances](https://github.com/debops/ansible-owncloud)

  Automation framework for setting up ownCloud on any Debian based system. This offers much
  more flexibility and is not limited to Docker. So you can setup a ownCloud
  instance in a KVM virtual machine and/or a LXC container for example.

  This role is part of the [DebOps](http://debops.org/) project which allows
  you to automate all the steps mentioned above (setting up a Hypervisor host with
  support for KVM and/or LXC, setting up the virtual machine/container and
  installing Webserver/PHP/Database and finally ownCloud).

  The real fun with this approach begins when you manage multiple instances
  because Ansible and this role allow you to run actions like ownCloud updates
  or enabling apps or the like on all your instances automatically.

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
[this.project_docker_hub_url]: https://hub.docker.com/r/jchaney/owncloud/
[this.project_github_url]: https://github.com/jchaney/owncloud
[Automated builds]: https://docs.docker.com/docker-hub/builds/
