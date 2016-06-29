# -*- mode: ruby -*-
# vi: set ft=ruby :

$init = <<SCRIPT
# Update apt and get dependencies
echo Installing dependencies ....
sudo apt-get update >>/dev/null
sudo apt-get install -y unzip curl wget vim
echo done.
SCRIPT

$nomad = <<SCRIPT
# Download Nomad
echo Fetching Nomad...
cd /tmp/
curl -sSL https://releases.hashicorp.com/nomad/0.3.2/nomad_0.3.2_linux_amd64.zip -o nomad.zip
echo Installing Nomad...
unzip nomad.zip
sudo chmod +x nomad
sudo mv nomad /usr/bin/nomad
sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d
SCRIPT

$nomad_server = <<SCRIPT
nomad version
cat /vagrant/nomad.server.hcl
sudo cp -v /vagrant/nomad.server.hcl /etc/nomad
echo -n "Starting nomad server ... "
sudo cp  -v /vagrant/nomad.upstart.conf /etc/init/nomad.conf
sudo service nomad restart
sleep 5
echo done.
export NOMAD_ADDR=http://192.168.0.11:4646
nomad server-members
nomad node-status
SCRIPT

$nomad_client = <<SCRIPT
nomad version
cat /vagrant/nomad.client.hcl
sudo cp -v /vagrant/nomad.client.hcl /etc/nomad
echo -n "Starting nomad client ... "
sudo cp  -v /vagrant/nomad.upstart.conf /etc/init/nomad.conf
sudo service nomad restart
sleep 5
echo done.
nomad node-status
SCRIPT


$consul = <<SCRIPT
echo Fetching Consul...
cd /tmp/
curl -sSL https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip -o consul.zip
echo Installing Consul...
unzip consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul
sudo mkdir /etc/consul.d
sudo chmod a+w /etc/consul.d
SCRIPT

$consul_server = <<SCRIPT
consul version
cat /vagrant/consul.server.json
consul configtest -config-file=/vagrant/consul.server.json
sudo cp -v /vagrant/consul.server.json /etc/consul
echo -n "Starting consul server ... "
sudo cp  -v /vagrant/consul.upstart.conf /etc/init/consul.conf
sudo service consul restart
sleep 5
echo done.
export CONSUL_RPC_ADDR=192.168.0.21:8400
consul members
SCRIPT

$consul_client = <<SCRIPT
consul version
cat /vagrant/consul.client.json
consul configtest -config-file=/vagrant/consul.client.json
sudo cp -v /vagrant/consul.client.json /etc/consul
echo -n "Starting consul client ... "
sudo cp  -v /vagrant/consul.upstart.conf /etc/init/consul.conf
sudo service consul restart
sleep 5
echo done.
export CONSUL_RPC_ADDR=192.168.0.31:8400
consul members
SCRIPT

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = false

  config.vm.define :nomad do |nomad|
    nomad.vm.hostname = "nomad"
    nomad.vm.network "private_network", ip: "192.168.0.11"
    nomad.vm.provision "shell", inline: $init, privileged: false
    nomad.vm.provision "shell", inline: $nomad, privileged: false
    nomad.vm.provision "shell", inline: $nomad_server, privileged: false
  end

  config.vm.define :consul do |consul|
    consul.vm.hostname = "consul"
    consul.vm.network "private_network", ip: "192.168.0.21"
    consul.vm.provision "shell", inline: $init, privileged: false
    consul.vm.provision "shell", inline: $consul, privileged: false
    consul.vm.provision "shell", inline: $consul_server, privileged: false
  end

  config.vm.define :client1 do |client1|
    client1.vm.hostname = "client1"
    client1.vm.network "private_network", ip: "192.168.0.31"
    client1.vm.provision "shell", inline: $init, privileged: false
    client1.vm.provision "shell", inline: $nomad, privileged: false
    client1.vm.provision "shell", inline: $nomad_client, privileged: false
    client1.vm.provision "shell", inline: $consul, privileged: false
    client1.vm.provision "shell", inline: $consul_client, privileged: false
    client1.vm.provision "docker" # just install it
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
end
