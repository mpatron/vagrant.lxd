# Virtualisation avec LXC/LCD sous Ubuntu 20.04 LTS

3 modes de virtualisation : VM, LXC, Container. Les VM sont une reproduction d'une machine complète et nécessitent donc
une consommation mémoire importante ainsi qu'une perte de puissance de CPU (presque 50% du CPU hard selon  [une étude IBM](./docs/1807.01842.pdf))

## Fabrication de la VM avec vagrant

Suite à un git clone

~~~bash
git clone git@github.com:mpatron/vagrant.lxd.git
~~~

Il faut télécharger l'image depuis [le site vagrant hub](https://app.vagrantup.com/generic/boxes/ubuntu2004). Puis mettre à jour de temps en temps. Et aussi de nétoyer les vielles images.

~~~powershell
vagrant init generic/ubuntu2004 # A ne faire qu'une seule fois
vagrant box update
vagrant box prune --force
~~~

Fini le ménage, on commence par lancer la VM :

~~~powershell
vagrant up --provision
vagran ssh # Connection à la VM Ubuntu 20.04 qui va porter LXC/LXD
~~~

## Installation de lxd

Suite au provisionning de vagrant les actions suivantes ne sont pas nécessaire car elles sont déjà réalisés.

~~~bash
sudo apt autoclean -y && sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge -y
sudo snap install lxd --channel=latest/stable
sudo adduser $USER lxd
newgrp lxd
~~~

## Lancement du premier container dans LXC/LXD

Créons une instance et listons les instances

~~~bash
vagrant@ubuntu2004:~$ lxc launch images:ubuntu/focal moninstance
Creating moninstance
Starting moninstance
vagrant@ubuntu2004:~$ lxc list
+-------------+---------+---------------------+------+-----------+-----------+
|    NAME     |  STATE  |        IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+---------------------+------+-----------+-----------+
| moninstance | RUNNING | 10.66.62.127 (eth0) |      | CONTAINER | 0         |
+-------------+---------+---------------------+------+-----------+-----------+
~~~

## Profile

La VM Hoster est configuré pour avoir 4 CPU et 4 Go, on peut le voir :

~~~bash
vagrant@ubuntu2004:~$ nproc && free -mh
4
              total        used        free      shared  buff/cache   available
Mem:          3.8Gi       297Mi       2.4Gi       1.0Mi       1.1Gi       3.3Gi
Swap:         1.9Gi          0B       1.9Gi
~~~

Vous avez déjà créé un container "moninstance", regardons ce qu'elle possède comme ressources :

~~~bash
vagrant@ubuntu2004:~$ lxc exec moninstance -- nproc && free -mh
4
              total        used        free      shared  buff/cache   available
Mem:          3.8Gi       299Mi       2.4Gi       1.0Mi       1.1Gi       3.3Gi
Swap:         1.9Gi          0B       1.9Gi
~~~

Le container a les mêmes ressources que le hoster. C'est le fonctionnement normal avec un profile par default. De même 
si vous créez une deuxième instance, les deux instances auront 100% des capacités du hoster.

~~~bash
vagrant@ubuntu2004:~$ lxc launch images:ubuntu/focal moninstance2
Creating moninstance2
Starting moninstance2
vagrant@ubuntu2004:~$ lxc list
+--------------+---------+---------------------+------+-----------+-----------+
|     NAME     |  STATE  |        IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+--------------+---------+---------------------+------+-----------+-----------+
| moninstance  | RUNNING | 10.66.62.127 (eth0) |      | CONTAINER | 0         |
+--------------+---------+---------------------+------+-----------+-----------+
| moninstance2 | RUNNING | 10.66.62.58 (eth0)  |      | CONTAINER | 0         |
+--------------+---------+---------------------+------+-----------+-----------+
vagrant@ubuntu2004:~$ lxc exec moninstance2 -- nproc && free -mh
4
              total        used        free      shared  buff/cache   available
Mem:          3.8Gi       310Mi       1.4Gi       1.0Mi       2.1Gi       3.3Gi
Swap:         1.9Gi          0B       1.9Gi
vagrant@ubuntu2004:~$ lxc exec moninstance -- nproc && free -mh
4
              total        used        free      shared  buff/cache   available
Mem:          3.8Gi       311Mi       1.4Gi       1.0Mi       2.1Gi       3.3Gi
Swap:         1.9Gi          0B       1.9Gi
~~~

Le mode du profile par default est souple, il partage les ressources. Mais cela peut être critique si les deux instances
consomment réélement les ressources, le plantage va arriver vite. Autant pour les CPU, le noyau fera bien sont jobs de répartir
la ressource de calcul de façon équitable, seul la durée des processus va s'allonger. Pour la mémoire, elle, s'il n'y en a plus, il n'y en a plus.
Pour faire de la gestion de la ressource, lxc.lxd a les profiles. En gros, cela ressemble aux types d'instances Amazon EC2.

vagrant@ubuntu2004:~$ lxc profile list
+---------+---------------------+---------+
|  NAME   |     DESCRIPTION     | USED BY |
+---------+---------------------+---------+
| default | Default LXD profile | 2       |
+---------+---------------------+---------+
vagrant@ubuntu2004:~$ lxc profile create monprofile
Profile monprofile created

vagrant@ubuntu2004:~$ lxc profile list
+------------+---------------------+---------+
|    NAME    |     DESCRIPTION     | USED BY |
+------------+---------------------+---------+
| default    | Default LXD profile | 2       |
+------------+---------------------+---------+
| monprofile |                     | 0       |
+------------+---------------------+---------+

lxc profile copy default monprofile

lxc exec moninstance bash
moninstance
