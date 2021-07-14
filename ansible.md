# On working

cloud-init-config_ssh_pub.yml
config:
user.user-data: |
  #cloud-config
  ssh_authorized_keys:
    - ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABBNn8mgexfqjgVaeKbr8eqgZkZQo0yTMnVDO2RB8Hv3p2w66HTBV4ZumsbJ0LbZq7ZDZ8la5Gl08Qg7Lb2tK3syADh7+aPGpi5V2WlEq7YwWPeIMmF8OgRFMYVShYpEVdYpJdgyBEch/mvq4cFANVBrLrWH9HHOisIcn6fLCsOe1gNhQ== vagrant@ubuntu2004.localdomain
  packages:
    - ssh
    - vim
    - jq
Y mettre le contenue de :
cat ~/.ssh/id_ecdsa.pub

lxc profile create sshprofile
ou
lxc profile copy default sshprofile
lxc profile set sshprofile user.user-data - < cloud-init-config_ssh_pub.yml
lxc launch images:ubuntu/focal moninstance3 --profile sshprofile

port mapping :
https://blog.simos.info/how-to-use-the-lxd-proxy-device-to-map-ports-between-the-host-and-the-containers/

passerelle ssh
https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-ubuntu-20-04-fr

Un cheatsheets
https://www.digitalocean.com/community/cheatsheets/how-to-use-ansible-cheat-sheet-guide


ssh-keygen -t ecdsa -b 521 -f ~/.ssh/id_ecdsa
cat ~/.ssh/id_ecdsa.pub | lxc exec <container> -- sh -c "cat >> /home/ubuntu/.ssh/authorized_keys"
agrant@ubuntu2004:~$ ssh-keygen -t ecdsa -b 521 -f ~/.ssh/id_ecdsa
Generating public/private ecdsa key pair.
/home/vagrant/.ssh/id_ecdsa already exists.
Overwrite (y/n)? y
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/vagrant/.ssh/id_ecdsa
Your public key has been saved in /home/vagrant/.ssh/id_ecdsa.pub
The key fingerprint is:
SHA256:+xlT/kjm/BrzHRHtigL49oGYnd8VxQ6lHZy+ihQk/3w vagrant@ubuntu2004.localdomain
The key's randomart image is:
+---[ECDSA 521]---+
|              ..o|
|         . .   Bo|
|          +   +.=|
|       .   o   *.|
|      . S   = ..+|
|       = = + + E.|
|      o B * O =. |
|       . + & O ..|
|          = *o+ .|
+----[SHA256]-----+
lxc exec moninstance -- apt install -y ssh
vagrant@ubuntu2004:~$ ls ~/.ssh/
authorized_keys  id_ecdsa  id_ecdsa.pub
vagrant@ubuntu2004:~$ cat ~/.ssh/id_ecdsa.pub | lxc exec moninstance -- sh -c "cat >> /home/ubuntu/.ssh/authorized_keys"
sh: 1: cannot create /home/ubuntu/.ssh/authorized_keys: Directory nonexistent
vagrant@ubuntu2004:~$ lxc exec moninstance -- sh -c "mkdir /home/ubuntu/.ssh/"
vagrant@ubuntu2004:~$ lxc exec moninstance -- sh -c "chmod 700 /home/ubuntu/.ssh/"
vagrant@ubuntu2004:~$ cat ~/.ssh/id_ecdsa.pub | lxc exec moninstance -- sh -c "cat >> /home/ubuntu/.ssh/authorized_keys"
vagrant@ubuntu2004:~$ lxc exec moninstance -- systemctl restart ssh
Failed to restart ssh.service: Unit ssh.service not found.
vagrant@ubuntu2004:~$ lxc exec moninstance -- systemctl restart sshd
Failed to restart sshd.service: Unit sshd.service not found.
vagrant@ubuntu2004:~$

~/.ssh/config
Host *.lxd
    User ubuntu
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ProxyCommand nc $(lxc list -c s4 $(echo %h | sed "s/\.lxd//g") | grep RUNNING | cut -d' ' -f4 | head -n1 ) %p
 
Host *.vm
    #StrictHostKeyChecking no
    #UserKnownHostsFile /dev/null
    ProxyCommand nc $(virsh domifaddr $(echo %h | sed "s/\.vm//g") | awk -F'[ /]+' '{if (NR>2 && $5) print $5}') %p


ansible all -m ping -u root
ansible all -vvv -m raw -a "ls -la /tmp"
ansible-inventory --list -y
grep -Ev "(^#|^[[:blank:]]*$)" /etc/ansible/hosts
cat /etc/hosts
sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config

ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "john@example.com"
ssh -4 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_ed25519 root@10.183.83.172
ansible all -v -u root -m raw -a "ls -la /"

vagrant@ubuntu2004:~$ grep -Ev "(^#|^[[:blank:]]*$)" /etc/ansible/hosts
[servers]
moninstance3 ansible_ssh_host=moninstance3
[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_connection=lxd




apt-get install linux-image-$(uname -r)
'jupyterhub-singleuser'

# Installation de kubectl mano
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
mkdir ~/.kube
lxc file pull kmaster/etc/kubernetes/admin.conf ~/.kube/config
kubectl get nodes
kubectl get pods --all-namespaces

# Installation de kubectl apt-get
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# Installation de kubectl completion
apt-get install bash-completion
sudo bash -c "kubectl completion bash >/etc/bash_completion.d/kubectl"
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc

sudo bash -c "curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash"
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update


# optimisation du hoster
# mettre le cache des carte réseau à 32Mo
sudo sysctl -w net.core.rmem_max=31457280
sudo sysctl -w net.core.wmem_max=31457280
# limiter l'utilisation du disque, déclanché son utilisation dès que 100-10=90% de la ram est utilisé, pas avant.
sudo sysctl -w vm.swappiness=10
sudo bash -c "echo 'net.core.wmem_max=31457280' >> /etc/sysctl.conf"
sudo bash -c "echo 'net.core.rmem_max=31457280' >> /etc/sysctl.conf"
sudo bash -c "echo 'vm.swappiness=10' >> /etc/sysctl.conf"
# La prise en compte de la modification du swappiness se fait soit au reboot soit en déactivant/reactivant le swap
swapoff -a
swapon -a


Edit the file /etc/sysctl.conf and add the following:
net.core.wmem_max = 16777216
net.core.wmem_default = 131072
net.core.rmem_max = 16777216
net.core.rmem_default = 131072
net.ipv4.tcp_rmem = 4096 131072 16777216
net.ipv4.tcp_wmem = 4096 131072 16777216
net.ipv4.tcp_mem = 4096 131072 16777216
net.core.netdev_max_backlog = 30000
net.ipv4.ipfrag_high_threshold = 8388608
run /sbin/sysctl -p



# Des trucs intéressants
https://github.com/justmeandopensource/kubernetes/tree/master/lxd-provisioning

lxc stop kmaster kworker{1,2}
lxc delete kmaster kworker{1,2}


curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm


https://zero-to-jupyterhub.readthedocs.io/en/latest/jupyterhub/installation.html
https://zero-to-jupyterhub.readthedocs.io/en/stable/resources/reference.html
