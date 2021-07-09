# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"
  # Génère un bus de force le mot de passe de root
  # config.ssh.username = 'root'
  # config.ssh.password = 'vagrant'
  # config.ssh.insert_key = 'true'
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "8192"
	  vb.cpus = 8
  end
  config.vm.provision "shell", run: "always", inline: <<-SHELL1
    sudo apt autoclean -y && sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge -y
    sudo apt -y install rng-tools iftop htop lsof sshpass
    sudo apt -y install ansible ssh jq
    sudo sed -i -e "\\#PasswordAuthentication yes# s#PasswordAuthentication yes#PasswordAuthentication yes#g" /etc/ssh/sshd_config
    sudo systemctl restart sshd
    sudo snap install lxd --channel=4.0/stable
    sudo adduser $USER lxd
    sudo lxd init --auto
  SHELL1
end
