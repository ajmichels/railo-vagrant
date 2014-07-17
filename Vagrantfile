# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

    config.vm.box = "precise32"

    config.vm.network :private_network, ip: "192.168.33.10"

    config.vm.synced_folder ".", "/var/www", group: "www-data", owner: "www-data"

    config.vm.provision :shell, :path => ".vagrant/bootstrap.sh"
    config.vm.provision :shell, :path => ".vagrant/railo.sh"


end
