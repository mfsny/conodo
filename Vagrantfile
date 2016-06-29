# -*- mode: ruby -*-
# vi: set ft=ruby :

$init = <<SCRIPT
# Update apt and get dependencies
echo Installing dependencies ....
sudo apt-get update >>/dev/null
sudo apt-get install -y unzip curl wget vim
echo done.
ifconfig eth1 | grep "inet addr" | awk 'BEGIN { FS = "[ :]+" }{print $4}' >/tmp/self.ip
export IP_ADDRESS=$(cat /tmp/self.ip)
echo IP_ADDRESS=$IP_ADDRESS
SCRIPT

$nomad = <<SCRIPT
# Download Nomad
echo Fetching Nomad...
curl -sSL https://releases.hashicorp.com/nomad/0.3.2/nomad_0.3.2_linux_amd64.zip -o nomad.zip
echo Installing Nomad...
unzip nomad.zip
sudo chmod +x nomad
sudo mv nomad /usr/bin/nomad
sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d
SCRIPT

$nomad_server = <<SCRIPT
export IP_ADDRESS=$(cat /tmp/self.ip)
echo IP_ADDRESS=$IP_ADDRESS
nomad version
cat /vagrant/nomad.server.hcl
sudo cp -v /vagrant/nomad.server.hcl /etc/nomad
echo -n "Starting nomad server ... "
sudo cp  -v /vagrant/nomad.upstart.conf /etc/init/nomad.conf
sudo service nomad restart
sleep 5
echo done.
echo -n "Adjusting profile ... "
if ! grep -q "export NOMAD_ADDR=http" ~/.profile
then
  echo "export NOMAD_ADDR=http://$IP_ADDRESS:4646" >>~/.profile
else
  sed -i "sed|.*export NOMAD_ADDR=http.*|export NOMAD_ADDR=http://$IP_ADDRESS:4646|" >>~/.profile
fi
echo done.
echo -n "Testing configuration ... "
export NOMAD_ADDR=http://$IP_ADDRESS:4646
nomad server-members
nomad node-status
echo done.
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
echo -n "Testing configuration ... "
nomad node-status
echo done.
SCRIPT


$consul = <<SCRIPT
echo Fetching Consul...
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
echo -n "Adjusting profile ... "
export CONSUL_RPC_ADDR=192.168.0.21:8400
echo done.
echo -n "Testing configuration ... "
consul members
echo done.
SCRIPT

$consul_client = <<SCRIPT
consul version
export IP_ADDRESS=$(cat /tmp/self.ip)
echo IP_ADDRESS=$IP_ADDRESS
sudo cp -v /vagrant/consul.client.json /etc/consul
sudo sed -i s/192.168.0.3x/$IP_ADDRESS/g /etc/consul
cat /etc/consul
consul configtest -config-file=/etc/consul
echo -n "Starting consul client ... "
sudo cp  -v /vagrant/consul.upstart.conf /etc/init/consul.conf
sudo service consul restart
sleep 5
echo done.
echo -n "Testing configuration ... "
export CONSUL_RPC_ADDR=$IP_ADDRESS:8400
consul members
echo done.
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

(1..3).each do |i|
  config.vm.define "client#{i}" do |client|
    client.vm.hostname = "client#{i}"
    client.vm.network "private_network", ip: "192.168.0.3#{i}"
    client.vm.provision "shell", inline: $init, privileged: false
    client.vm.provision "shell", inline: $nomad, privileged: false
    client.vm.provision "shell", inline: $nomad_client, privileged: false
    client.vm.provision "shell", inline: $consul, privileged: false
    client.vm.provision "shell", inline: $consul_client, privileged: false
    client.vm.provision "docker" # just install it
  end
end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
end
