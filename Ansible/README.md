# Table of contents

**How was this developed?**

- Vagrantfile
- Ansible playbook
- Roles

# How was this developed?

## Vagrantfile

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
config.vm.provision "ansible_local" do |ansible|
     ansible.config_file = "ansible/ansible.cfg"
     ansible.playbook = "ansible/plays/playbook.yml"
     ansible.groups = {
       "servers" => ["server"],
       "clients" => ["agent1","agent2"],
       "clients:vars" => {"consul_server" => false, "nomad_server" => false, "nomad_client" => true},
       "servers:vars" => {"consul_server" => true, "nomad_server" => true, "nomad_client" => false}
     }
     # use this to get more detailed error information
     ansible.verbose = '-vvv' 
  end
```

This was the main info needed for the Vagrantfile, if anything is unclear, the Vagrantfile is documentated more detailed in the [first assignment](https://github.com/GiulianoArgentinoPXL/PXL_nomad/tree/team19/Nomad).

## Ansible playbook

The content for the playbook is really short, we seperate the clients from the servers so we don't need to install unnecessary services. As you can, differentiating both groups isn't completely necessary here, however it's still a good practice for when it actually is necessary. If we put `hosts: all`, **Docker** would also be installed on the server.

```yaml
- become: true # become root
  hosts: clients # all the nodes that are in the client group as defined in the Vagrantfile
  name: "playbook for client vms"
  roles: 
    - role: software/docker
    - role: software/consul
    - role: software/nomad



- become: true # become root
  hosts: servers # all the nodes that are in the client group as defined in the Vagrantfile
  name: "playbook for server vms" 
  roles: 
    - role: software/consul
    - role: software/nomad
```

## Roles

As for the roles, we mixed up using 2 different techniques to learn how both techniques work, now what are we exactly talking about? If you take a look at [consul.hcl.j2](https://github.com/GiulianoArgentinoPXL/PXL_nomad/blob/team19/Ansible/ansible/roles/software/consul/templates/consul.hcl.j2) (this is a template file which will be used for the configuration for **Consul**), we used an if statement to determine if the specified node is a client or server. Whileas in the [Nomad templates](https://github.com/GiulianoArgentinoPXL/PXL_nomad/tree/team19/Ansible/ansible/roles/software/nomad/templates) we have 2 seperate configuration files instead of using an if statement to determine the difference. Now you might might ask, where do you choose which config file you want to use?

If you take a look at the [Nomad task](https://github.com/GiulianoArgentinoPXL/PXL_nomad/blob/team19/Ansible/ansible/roles/software/nomad/tasks/main.yml) you can see a `when: nomad_server` and `when: nomad_client` line. If you paid attention, you can remember this from the **Vagrantfile** which we talked about earlier, where we define the groups.

```yaml
- name: Create Nomad server configuration file
  template:
    src: server.hcl.j2
    dest: /etc/nomad.d/nomad.hcl
    owner: "nomad"
    group: "nomad"
    mode: 0644
  notify: restart nomad
  when: nomad_server

- name: Create Nomad client configuration file
  template:
    src: client.hcl.j2
    dest: /etc/nomad.d/nomad.hcl
    owner: "nomad"
    group: "nomad"
    mode: 0644
  notify: restart nomad
  when: nomad_client
  ```
  
  ```
 ansible.groups = {
       "servers" => ["server"],
       "clients" => ["agent1","agent2"],
       "clients:vars" => {"consul_server" => false, "nomad_server" => false, "nomad_client" => true},
       "servers:vars" => {"consul_server" => true, "nomad_server" => true, "nomad_client" => false}
     }
 ```
 
 By using both groups and conditional statements in our assignment, we learned to work with both which is never a bad case!

https://learn.hashicorp.com/tutorials/consul/get-started-create-datacenter?in=consul%2Fgetting-started&fbclid=IwAR1lVFYM9e_ELX9v-aOq18Cet9bAxYZuKBYCOkCZHNP3F35l5h-NJgyyIGg
