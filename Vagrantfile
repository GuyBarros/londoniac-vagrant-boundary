# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure(2) do |config|

  config.vm.provider "parallels" do |p, o|
      p.memory = "1024"
    end
    # Increase memory for Virtualbox
    config.vm.provider "virtualbox" do |vb|
          vb.memory = "1024"
    end
    # Increase memory for VMware
    ["vmware_fusion", "vmware_workstation"].each do |p|
      config.vm.provider p do |v|
        v.vmx["memsize"] = "1024"
        v.vmx["numvcpus"] = "2"
      end
    end
  #  config.vm.provision "shell", path: "bootstrap.sh"

  ServerCount = 1
  # Demostack Server Nodes
  (1..ServerCount).each do |i|
    config.vm.define "nserver#{i}" do |servernode|
      servernode.vm.box = "bento/ubuntu-20.04"
      servernode.vm.hostname = "nserver#{i}.node.consul"
      servernode.vm.network "public_network", use_dhcp_assigned_default_route: true
      servernode.vm.network "private_network", ip: "172.17.16.10#{i}"
      servernode.vm.network "forwarded_port", guest: "8500", host: "5#{i}00"
      servernode.vm.provision "shell", path: "scripts/bootstrap.sh", preserve_order: true
      servernode.vm.provision "shell", path: "scripts/server/consul.sh", preserve_order: true , run:"after"
      servernode.vm.provision "shell", path: "scripts/server/vault.sh", preserve_order: true , run:"after"
      servernode.vm.provision "shell", path: "scripts/server/nomad.sh", preserve_order: true , run:"after"
    end
  end

  # config.trigger.after :up do |trigger|
  #   trigger.name = "Vault Setup"
  #   trigger.info = "running vault on nserver1 config after vagrant up finishes"
  #     config.vm.define "nserver1" do |servernode|
  #     servernode.vm.provision "shell", path: "scripts/server/vault-setup.sh", preserve_order: true
  #   end
  # end



    # WorkerCount = 3
    # # Demostack Worker Nodes
    # (1..WorkerCount).each do |i|
    #   config.vm.define "nworker#{i}" do |workernode|
    #     workernode.vm.box = "bento/ubuntu-20.04"
    #     workernode.vm.hostname = "nworker#{i}.example.com"
    #     workernode.vm.network "private_network", ip: "172.16.16.20#{i}"
    #     workernode.vm.provision "shell", path: "scripts/base.sh"
    #     servernode.vm.provision "shell", path: "scripts/docker.sh"
    #   end
    # end

  end
