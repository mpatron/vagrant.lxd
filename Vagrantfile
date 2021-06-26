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
    vb.memory = "4096"
	vb.cpus = 4
  end
  config.vm.provision "shell", run: "always", inline: <<-SHELL1
    sudo apt autoclean -y && sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge -y
    sudo apt -y install rng-tools iftop htop lsof sshpass
    sudo sed -i -e "\\#PasswordAuthentication no# s#PasswordAuthentication no#PasswordAuthentication yes#g" /etc/ssh/sshd_config
    sudo systemctl restart sshd
    sudo snap install lxd --channel=4.0/stable
    sudo adduser $USER lxd
  SHELL1
end
