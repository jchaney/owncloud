# -*- mode: ruby -*-
# vi: set ft=ruby :

## Vagrant can be used for development if you are into Vagrant.
## Note that the Makefile has much more options …

Vagrant.configure("2") do |config|
  config.vm.provider "docker" do |docker|
    docker.image = "jchaney/owncloud"
    docker.name = "owncloud-dev"
    docker.env = { TZ: 'Europe/Berlin', OWNCLOUD_IN_ROOTPATH: '1' }
    docker.ports = ['80:80', '443:443']

  end
  ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'
  # config.vm.provider "docker"
end
