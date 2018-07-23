# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.define "benchmark" do |node|
    node.vm.box = "bento/ubuntu-16.04"
    node.vm.network "private_network", ip: "172.17.0.2"
    node.vm.provision "shell", path: "setup/pg_setup_ubuntu.sh"
    node.vm.provision "shell", path: "setup/mongo_setup_ubuntu.sh"
  end

  config.vm.define "mongo" do |node|
    node.vm.box = "bento/ubuntu-16.04"
    node.vm.network "private_network", ip: "172.17.0.3"
    node.vm.provision "shell", path: "setup/mongo_setup_ubuntu.sh"
  end

  config.vm.define "pg" do |node|
    node.vm.box = "bento/ubuntu-16.04"
    node.vm.network "private_network", ip: "172.17.0.4"
    node.vm.provision "shell", path: "setup/pg_setup_ubuntu.sh"
  end
end
