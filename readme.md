# Virtualisation avec LXC/LCD sous Ubuntu 20.04 LTS

3 modes de virtualisation : VM, LXC, Container. Les VM sont une reproduction d'une machine complète et nécessitent donc
une consommation mémoire importante ainsi qu'une perte de puissance de CPU (presque 50% du CPU hard selon  [une étude IBM](./docs/1807.01842.pdf))

## Fabrication de la VM avec vagrant

~~~powershell
vagrant init generic/ubuntu2004 # A ne faire qu'une seule fois
vagrant box update
vagrant 
vagrant up
vagran ssh
~~~

## Installation de lxd

~~~bash
sudo apt autoclean -y && sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge -y
sudo snap install lxd --channel=latest/stable
sudo adduser $USER lxd
newgrp lxd
~~~

~~~bash
lxc launch images:ubuntu/focal moninstance
lxc network list
~~~
