#!/bin/bash
# Source : https://github.com/justmeandopensource/kubernetes/tree/master/lxd-provisioning
usage()
{
  echo "Usage: kubelx [provision|destroy|start|stop]"
  exit 1
}

NODES="kmaster kworker1 kworker2"

kubeprovision()
{
  # check if we have k8s profile or create one
  lxc profile list | grep -qo k8s || (lxc profile create k8s && cat k8s-profile-config | lxc profile edit k8s)
  echo
  for node in $NODES
  do
    echo "==> Bringing up $node"
    lxc launch ubuntu:20.04 $node --profile k8s
    sleep 10
    echo "==> Running provisioner script"
    cat bootstrap-kube.sh | lxc exec $node bash
    echo
  done
  mkdir ~/.kube
  lxc file pull kmaster/etc/kubernetes/admin.conf ~/.kube/config
  ls -l ~/.kube
  sudo apt-get update && sudo apt-get install -y apt-transport-https
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubectl
  kubectl get nodes
}

kubedestroy()
{
  for node in $NODES
  do
    echo "==> Destroying $node..."
    lxc delete --force $node
  done
}

kubestartall()
{
  for node in $NODES
  do
    echo "==> Starting $node..."
    lxc start $node
  done
}

kubestopall()
{
  for node in $NODES
  do
    echo "==> Stopping $node..."
    lxc stop $node
  done
}

case "$1" in
  provision)
    echo -e "\nProvisioning Kubernetes Cluster...\n"
    kubeprovision
    ;;
  destroy)
    echo -e "\nDestroying Kubernetes Cluster...\n"
    kubedestroy
    ;;
  start)
    echo -e "\nStarting Kubernetes Cluster...\n"
    kubestartall
    ;;
  stop)
    echo -e "\nStopping Kubernetes Cluster...\n"
    kubestopall
    ;;
  *)
    usage
    ;;
esac
