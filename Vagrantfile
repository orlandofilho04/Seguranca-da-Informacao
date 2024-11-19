# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    # MAQUINA GATEWAY
    config.vm.define "vm1" do |vm1|
      vm1.vm.hostname = "vm1"
      vm1.vm.box = "ubuntu/focal64"
      vm1.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
      end
      vm1.vm.network "private_network", type: "private_network", ip: "192.168.56.10"
      vm1.vm.synced_folder "./DockerWeb", "/VagrantWeb"
      vm1.vm.network "forwarded_port", guest: 80, host: 8081
      vm1.vm.provision "shell", path: "provisioners/web_provision.sh"
    end
    #MAQUINA CLIENTE
    config.vm.define "vm2" do |vm2|
      vm2.vm.hostname = "vm2"
      vm2.vm.box = "ubuntu/focal64"
      vm2.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2

      end
        vm2.vm.network "private_network", type: "dhcp"
        vm2.vm.provision "shell", path: "provisioners/vm2_provision.sh"
    end
  end