lxc profile create k8s
cat k8s-profile-config | lxc profile edit k8s
lxc profile list
lxc launch ubuntu:20.04 kmaster --profile k8s
lxc launch ubuntu:20.04 kworker1 --profile k8s
lxc launch ubuntu:20.04 kworker2 --profile k8s
lxc list
cat bootstrap-kube.sh | lxc exec kmaster bash
cat bootstrap-kube.sh | lxc exec kworker1 bash
cat bootstrap-kube.sh | lxc exec kworker2 bash
lxc list

mkdir ~/.kube
lxc file pull kmaster/etc/kubernetes/admin.conf ~/.kube/config
ls -l ~/.kube
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
kubectl get nodes
