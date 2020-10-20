# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
BOX_IMAGE = "centos/7"
NODE_COUNT = 2
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = BOX_IMAGE
  config.vm.provision "shell", inline: "hostname"
  config.vm.provision "shell", path: "scriptsPE/update.sh"
  config.vm.provision "shell", path: "scriptsPE/docker_install.sh"
  config.vm.provision "shell", path: "scriptsPE/nomad_install.sh"
  config.vm.provision "shell", path: "scriptsPE/consul_install.sh"
  config.vm.provision "shell", inline: <<-SHELL
		export NOMAD_ADDR=http://10.0.0.10:4646
  SHELL
  config.vm.provider :virtualbox do |virtualbox, override|
    virtualbox.customize ["modifyvm", :id, "--memory", 2048]
  end
  
  config.vm.provider :lxc do |lxc, override|
    override.vm.box = "visibilityspots/centos-7.x-minimal"
  end

  config.vm.define "nomadserver" do |nomadserver|
    nomadserver.vm.hostname = "SERVER"
    nomadserver.vm.network :private_network, ip: "10.0.0.10", virtualbox__intnet: true, auto_config: true
	nomadserver.vm.provision "shell", inline: <<-SHELL
		echo -e 'data_dir = "/opt/consul" \nclient_addr = "0.0.0.0" \nui = true \nserver = true \nbootstrap_expect=1 \nbind_addr = "{{ GetInterfaceIP \\"eth1\\" }}"' > /etc/consul.d/consul.hcl
		echo -e 'data_dir = "/opt/nomad/data" \nbind_addr = "10.0.0.10" \nserver {\nenabled = true  \nbootstrap_expect = 1 \n}' > /etc/nomad.d/nomad.hcl
	SHELL
	end
  
  (1..NODE_COUNT).each do |i|
     config.vm.define "agent#{i}" do |subconfig|
       subconfig.vm.box = BOX_IMAGE
       subconfig.vm.hostname = "AGENT#{i}"
       subconfig.vm.network :private_network, ip: "10.0.0.#{i + 10}", virtualbox__intnet: true, auto_config: true
	   subconfig.vm.provision "shell", inline: <<-SHELL
		 echo -e 'data_dir = "/opt/consul" \nclient_addr = "0.0.0.0" \nui = true \nbind_addr = "{{ GetInterfaceIP \\"eth1\\" }}" \nretry_join = ["10.0.0.10"]' > /etc/consul.d/consul.hcl
		 echo -e 'data_dir = "/opt/nomad/data" \nbind_addr = "0.0.0.0" \nclient {\nenabled = true  \nservers = ["10.0.0.10"]\n}' > /etc/nomad.d/nomad.hcl		 
	   SHELL
	 end
   end 
end
