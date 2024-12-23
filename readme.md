# Virtualisation avec LXC/LCD sous Ubuntu 20.04 LTS

3 modes de virtualisation : VM, LXC, Container. Les VM sont une reproduction d'une machine complète et nécessitent donc
une consommation mémoire importante ainsi qu'une perte de puissance de CPU (presque 50% du CPU hard selon  [une étude IBM](./docs/1807.01842.pdf))

## Installation de vagrant

~~~bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
~~~

## Fabrication de la VM avec vagrant

Suite à un git clone

~~~bash
git clone git@github.com:mpatron/vagrant.lxd.git
~~~

Il faut télécharger l'image depuis [le site vagrant hub](https://app.vagrantup.com/generic/boxes/ubuntu2004). Puis mettre à jour de temps en temps. Et aussi de nétoyer les vielles images.
OU trouver une image qui vous convient dans [https://portal.cloud.hashicorp.com/vagrant/discover](https://portal.cloud.hashicorp.com/vagrant/discover)

generic/debian12

~~~powershell
vagrant init generic/ubuntu2004 # A ne faire qu'une seule fois
vagrant box update
vagrant box prune --force
~~~

Fini le ménage, on commence par lancer la VM :

~~~powershell
vagrant up --provision --provider=virtualbox
vagran ssh # Connection à la VM Ubuntu 20.04 qui va porter LXC/LXD
~~~

A la fin, pour détruire la VM :

~~~powershell
vagrant destroy --force
~~~

## Installation de lxd

Suite au provisionning de vagrant les actions suivantes ne sont pas nécessaire car elles sont déjà réalisés.

~~~bash
sudo apt autoclean -y && sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge -y
# cd /vagrant && PYTHONUNBUFFERED=1 ANSIBLE_NOCOLOR=False ANSIBLE_CONFIG=ansible.cfg ansible-playbook --limit="all" --inventory-file=inventory.txt --extra-vars=\{\"PROXY_ON\":false,\"PROXY_SERVER\":\"\"\} -v provision.yml

sudo snap install lxd --channel=latest/stable
sudo adduser $USER lxd
newgrp lxd
# Avant tout, on configure lxd par default
lxd init --auto
~~~

Status du service lxd

~~~bash
sudo snap services lxd
sudo snap restart lxd
sudo snap start --enable lxd.daemon ## Pas très recommandé en snap
sudo snap stop --disable lxd.daemon ## Pas très recommandé en snap
sudo snap logs lxd
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

Pour ouvrir une session, c'est une exécution de bash :

~~~bash
vagrant@ubuntu2004:~$ lxc exec moninstance bash
root@moninstance:~# df -kh
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda3       124G  4.2G  113G   4% /
none            492K  4.0K  488K   1% /dev
udev            1.9G     0  1.9G   0% /dev/tty
tmpfs           100K     0  100K   0% /dev/lxd
tmpfs           100K     0  100K   0% /dev/.lxd-mounts
tmpfs           2.0G     0  2.0G   0% /dev/shm
tmpfs           394M  104K  394M   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           2.0G     0  2.0G   0% /sys/fs/cgroup
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
Au commencement, il n'y a que le profile par default.

~~~bash
vagrant@ubuntu2004:~$ lxc profile list
+---------+---------------------+---------+
|  NAME   |     DESCRIPTION     | USED BY |
+---------+---------------------+---------+
| default | Default LXD profile | 2       |
+---------+---------------------+---------+
~~~

On peut le créer, mais ce n'est pas pratique car on récupère un profile vide.

~~~bash
vagrant@ubuntu2004:~$ lxc profile create monprofile
Profile monprofile created
vagrant@ubuntu2004:~$ lxc profile show monprofile
config: {}
description: ""
devices: {}
name: monprofile
used_by: []
vagrant@ubuntu2004:~$ lxc profile show default
config: {}
description: Default LXD profile
devices:
  eth0:
    name: eth0
    network: lxdbr0
    type: nic
  root:
    path: /
    pool: default
    type: disk
name: default
used_by:
- /1.0/instances/moninstance
- /1.0/instances/moninstance2
~~~

Il est préférable de partir du profile par default en le copiant le modifiant :

~~~bash
vagrant@ubuntu2004:~$ lxc profile copy default monprofile
vagrant@ubuntu2004:~$ lxc profile edit monprofile
### This is a YAML representation of the profile.
### Any line starting with a '# will be ignored.
###
### A profile consists of a set of configuration items followed by a set of
### devices.
###
### An example would look like:
### name: onenic
### config:
###   raw.lxc: lxc.aa_profile=unconfined
### devices:
###   eth0:
###     nictype: bridged
###     parent: lxdbr0
###     type: nic
###
### Note that the name is shown but cannot be changed

config:
  limits.cpu: "2"
  limits.memory: 2GB
description: Default LXD profile
devices:
  eth0:
    name: eth0
    network: lxdbr0
    type: nic
  root:
    path: /
    pool: default
    type: disk
name: monprofile
used_by: []
~~~

Pour vous aidez à remplir les paramètres la complession peut vous aider:

~~~bash
vagrant@ubuntu2004:~$ lxc profile get monprofile <TAB><TAB>
boot.autostart                             nvidia.require.driver                      security.syscalls.intercept.mount
boot.autostart.delay                       nvidia.runtime                             security.syscalls.intercept.mount.allowed
boot.autostart.priority                    raw.apparmor                               security.syscalls.intercept.mount.fuse
boot.host_shutdown_timeout                 raw.idmap                                  security.syscalls.intercept.mount.shift
boot.stop.priority                         raw.lxc                                    security.syscalls.intercept.setxattr
environment.                               raw.qemu                                   snapshots.expiry
limits.cpu                                 raw.seccomp                                snapshots.pattern
limits.cpu.allowance                       security.devlxd                            snapshots.schedule
limits.cpu.priority                        security.devlxd.images                     snapshots.schedule.stopped
limits.disk.priority                       security.idmap.base                        user.meta-data
limits.kernel                              security.idmap.isolated                    user.network-config
limits.memory                              security.idmap.size                        user.network_mode
limits.memory.enforce                      security.nesting                           user.user-data
limits.memory.hugepages                    security.privileged                        user.vendor-data
limits.memory.swap                         security.protection.delete                 volatile.apply_quota
limits.memory.swap.priority                security.protection.shift                  volatile.apply_template
limits.network.priority                    security.secureboot                        volatile.base_image
limits.processes                           security.syscalls.allow                    volatile.idmap.base
linux.kernel_modules                       security.syscalls.deny                     volatile.idmap.current
migration.incremental.memory               security.syscalls.deny_compat              volatile.idmap.next
migration.incremental.memory.goal          security.syscalls.deny_default             volatile.last_state.idmap
migration.incremental.memory.iterations    security.syscalls.intercept.bpf            volatile.last_state.power
nvidia.driver.capabilities                 security.syscalls.intercept.bpf.devices
nvidia.require.cuda                        security.syscalls.intercept.mknod
vagrant@ubuntu2004:~$ lxc profile get monprofile limits.cpu
2
vagrant@ubuntu2004:~$ # Il est possible de setter directement une valeur
vagrant@ubuntu2004:~$ lxc profile set monprofile limits.cpu "3"
vagrant@ubuntu2004:~$ lxc profile get monprofile limits.cpu
3
~~~

L'instance qui a été créé est sur le profile par default, on veut donc qu'elle utilise la configuration typée. On remarque que
le nom de la valeur a un "s" car une instance peut avoir plusieur profile.
Deux methodes pour attribuer un profile, soit on l'affecter avec la commande **lxc profile add \<nom de l'instance> \<nom du profile>**

~~~bash
vagrant@ubuntu2004:~$ lxc info moninstance | grep -i profile
Profiles: default
vagrant@ubuntu2004:~$ lxc profile add moninstance <TAB><TAB>
default     monprofile
vagrant@ubuntu2004:~$ lxc profile add moninstance monprofile
Profile monprofile added to moninstance
vagrant@ubuntu2004:~$ lxc exec moninstance -- nproc && free -mh
3
              total        used        free      shared  buff/cache   available
Mem:          3.8Gi       307Mi       1.4Gi       1.0Mi       2.1Gi       3.3Gi
Swap:         1.9Gi          0B       1.9Gi
~~~

Soit au moment de la création, on lui attribut un profile:

~~~bash
vagrant@ubuntu2004:~$ lxc launch images:ubuntu/focal moninstance3 --profile monprofile
Creating moninstance3
Starting moninstance3
vagrant@ubuntu2004:~$ lxc info moninstance3 | grep -i profile
Profiles: monprofile
~~~

Grace à la documentation des API serveur de LXD [https://lxd.readthedocs.io/en/latest/rest-api/](https://lxd.readthedocs.io/en/latest/rest-api/) on peut réaliser un petit script qui permettra de mettre à jour /etc/hosts.

~~~bash
#/bin/bash

# L'objectif du script est de récupérer sur la sortie standard la liste des noms et ip des containers pour pouvoir les mettre
# facilement dans /etc/hosts.

# Le nom du serveur lxd est lxd à la suite d'une installation par snap.
# Un curl d'interrogation afin d'avoir la liste des instances
LIST_HOSTNAME=$(curl -s --unix-socket /var/snap/lxd/common/lxd/unix.socket -H "Content-Type: application/json" lxd/1.0/instances | jq '.metadata | .[] | .[15:]')

echo "### begin /etc/hosts ######"
for I_HOSTNAME in $LIST_HOSTNAME
do
        # Supression des " de la variable I_HOSTNAME
        I_HOSTNAME=$(echo $I_HOSTNAME | sed -e "s/\"//g")
        # Récupération de l'ip avec le nom du container
        IP_HOSTNAME=$( curl -s --unix-socket /var/snap/lxd/common/lxd/unix.socket -H "Content-Type: application/json" "lxd/1.0/instances/${I_HOSTNAME}/state" | jq '.metadata.network.eth0.addresses[] | select(.family=="inet").address' )
        # Supression des " de la variable IP_HOSTNAME
        IP_HOSTNAME=$(echo $IP_HOSTNAME | sed -e "s/\"//g")
        # Affichage sur la sorti standard
        echo $I_HOSTNAME $IP_HOSTNAME
done
echo "### end   /etc/hosts ######"
echo
echo "### begin /etc/ansible/hosts ######"
echo "[servers]"
for I_HOSTNAME in $LIST_HOSTNAME
do
        # Supression des " de la variable I_HOSTNAME
        I_HOSTNAME=$(echo $I_HOSTNAME | sed -e "s/\"//g")
        echo $I_HOSTNAME ansible_ssh_host=$I_HOSTNAME
done
echo [all:vars]
echo ansible_python_interpreter=/usr/bin/python3
echo ansible_connection=lxd
echo "### end   /etc/ansible/hosts ######"
~~~

## Lxd avec vagrant

Attention ici, c'est une autre histoire, ce n'est possible que sous un hoster linux à cause lxc/lxd, mais qu'est ce que c'est bien. C'est rapide à monter et à éxécuter. C'est la technique la plus rapide pour monter plusieur VM from scratch.

~~~bash
sudo apt-get install lxc-utils lxc-templates
vagrant plugin install vagrant-lxc
vagrant up --provider=lxc
~~~
