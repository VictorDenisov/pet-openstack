# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

MGMT_IP = "172.15.0.7"
PUBLIC_IP = "172.30.1.8"
PRIVATE_IP = "192.168.1.8"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "ubuntu14.04-server-amd64"
	config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

	config.vm.network "private_network", ip: MGMT_IP
	config.vm.network "private_network", ip: PUBLIC_IP
	config.vm.network "private_network", ip: PRIVATE_IP
	config.vm.synced_folder ".", "/vagrant", nfs: true

	config.vm.provider :virtualbox do |vb|
		vb.customize ["modifyvm", :id, "--cpus", "2"]
		vb.customize ["modifyvm", :id, "--memory", "2048"]
	end

	config.vm.provision "puppet" do |puppet|
		puppet.module_path = "modules"
		puppet.facter = {
			"mgmt_ip" => MGMT_IP,
			"public_ip" => PUBLIC_IP,
			"private_ip" => PRIVATE_IP,
		}
		puppet.hiera_config_path = "hiera.yaml"
	end
end
