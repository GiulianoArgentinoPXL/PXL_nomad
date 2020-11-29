# Nomad consul

The aim of this project is to provide a development environment based on [consul](https://www.consul.io) and [nomad](https://www.nomadproject.io) to manage container based microservices.

The following steps should make that clear;

bring up the environment by using [vagrant](https://www.vagrantup.com) which will create centos 7 virtualbox machine or lxc container.

The proved working vagrant providers used on an [ArchLinux](https://www.archlinux.org/) system are
* [vagrant-lxc](https://github.com/fgrehm/vagrant-lxc)
* [vagrant-libvirt](https://github.com/vagrant-libvirt/)
* [virtualbox](https://www.virtualbox.org/)

```bash
    $ vagrant up --provider lxc
    OR
    $ vagrant up --provider libvirt
    OR
    $ vagrant up --provider virtualbox
```

Once it is finished, you should be able to connect to the vagrant environment through SSH and interact with Nomad:

```bash
    $ vagrant ssh
    [vagrant@nomad ~]$
```

**To access the Web UI of Consul**

After the vagrant environment is set up successfully, type

```
    vagrant ssh <nomadserver> -- -L 8500:localhost:8500
```

**How was this developed?**

First of all we define our nodes with both a loop and manually. The server is hardcoded because theres only 1 and it needs a different name compared to the multiple agents.
You can add as many agents as you want by just increasing the `NODE_COUNT` variable at the top of the **Vagrantfile**.

```vagrant
NODE_COUNT = 2
config.vm.define "nomadserver" do |server|
    ...
end
(1..NODE_COUNT).each do |i|
     config.vm.define "agent#{i}" do |agent|
       ..
     end
end
```

Once the nodes have been defined, we can continue by using the Ansible provisioner. Here we indicate our **ansible.cfg** file with the correct path, and the same goes for our **playbook.yml**. Up next is setting the correct groups for the servers/clients, aswell as passing on variables towards a group which will be explained later on.

```vagrant
config.vm.provision "ansible" do |ansible|
     ansible.config_file = "ansible/ansible.cfg"
     ansible.playbook = "ansible/plays/playbook.yml"
     ansible.groups = {
       "servers" => ["server"],
       "clients" => ["agent1","agent2"],
       "servers:vars" => {"consul_server" => true, "nomad__server" => true}
     }
     ansible.verbose = '-vvv' 
  end
```



https://learn.hashicorp.com/tutorials/consul/get-started-create-datacenter?in=consul%2Fgetting-started&fbclid=IwAR1lVFYM9e_ELX9v-aOq18Cet9bAxYZuKBYCOkCZHNP3F35l5h-NJgyyIGg
