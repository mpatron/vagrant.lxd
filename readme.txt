
## Fabrication de la VM
vagrant init generic/ubuntu2004
vagrant up
vagran ssh

## Installation de lxd
sudo apt autoclean -y && sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge -y
sudo snap install lxd --channel=latest/stable
sudo adduser $USER lxd
newgrp lxd


lxc launch images:ubuntu/focal moninstance
lxc network list
