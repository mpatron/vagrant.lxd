
## installation de MetalLB

kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.10.2/manifests/metallb.yaml

kubectl get pod -n metallb-system -o wide

sudo snap install helm --classic
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb
helm install metallb metallb/metallb -f metallb_values.yaml

metallb_values.yaml
configInline:
  address-pools:
   - name: default
     protocol: layer2
     addresses:
     -192.168.59.0/24

https://www.enterprisedb.com/blog/how-deploy-pgadmin-kubernetes


vagrant@ubuntu2004:/vagrant/files$ kubectl get pod -o wide
NAME                                  READY   STATUS    RESTARTS   AGE     IP              NODE       NOMINATED NODE   READINESS GATES
metallb-controller-748756655f-cnzzl   1/1     Running   0          6h52m   10.244.1.2      kworker1   <none>           <none>
metallb-speaker-7s984                 1/1     Running   0          7m      10.232.49.167   kworker1   <none>           <none>
metallb-speaker-h7p5g                 1/1     Running   0          3m20s   10.232.49.59    kworker2   <none>           <none>
metallb-speaker-ldkmh                 1/1     Running   0          6h52m   10.232.49.199   kmaster    <none>           <none>
vagrant@ubuntu2004:/vagrant/files$ kubectl get nodes -o wide
NAME       STATUS   ROLES                  AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
kmaster    Ready    control-plane,master   17h     v1.21.0   10.232.49.199   <none>        Ubuntu 20.04.2 LTS   5.4.0-74-generic   containerd://1.5.2
kworker1   Ready    <none>                 8m32s   v1.21.0   10.232.49.167   <none>        Ubuntu 20.04.2 LTS   5.4.0-74-generic   containerd://1.5.2
kworker2   Ready    <none>                 5m11s   v1.21.0   10.232.49.59    <none>        Ubuntu 20.04.2 LTS   5.4.0-74-generic   containerd://1.5.2
vagrant@ubuntu2004:/vagrant/files$ kubectl get all --all-namespaces
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
default       pod/metallb-controller-748756655f-cnzzl   1/1     Running   0          10h
default       pod/metallb-speaker-7s984                 1/1     Running   0          4h5m
default       pod/metallb-speaker-h7p5g                 1/1     Running   0          4h1m
default       pod/metallb-speaker-ldkmh                 1/1     Running   0          10h
kube-system   pod/coredns-558bd4d5db-bz9hx              1/1     Running   0          21h
kube-system   pod/coredns-558bd4d5db-fqdnk              1/1     Running   0          21h
kube-system   pod/etcd-kmaster                          1/1     Running   0          21h
kube-system   pod/kube-apiserver-kmaster                1/1     Running   1          21h
kube-system   pod/kube-controller-manager-kmaster       1/1     Running   1          21h
kube-system   pod/kube-flannel-ds-8g5qn                 1/1     Running   1          4h6m
kube-system   pod/kube-flannel-ds-cb8nj                 1/1     Running   0          21h
kube-system   pod/kube-flannel-ds-cgkb5                 1/1     Running   0          4h3m
kube-system   pod/kube-proxy-4vfv2                      1/1     Running   0          4h6m
kube-system   pod/kube-proxy-ljfxq                      1/1     Running   0          4h3m
kube-system   pod/kube-proxy-rlx4h                      1/1     Running   0          21h
kube-system   pod/kube-scheduler-kmaster                1/1     Running   1          21h

NAMESPACE     NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
default       service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP                  21h
kube-system   service/kube-dns     ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   21h

NAMESPACE     NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
default       daemonset.apps/metallb-speaker   3         3         3       3            3           kubernetes.io/os=linux   10h
kube-system   daemonset.apps/kube-flannel-ds   3         3         3       3            3           <none>                   21h
kube-system   daemonset.apps/kube-proxy        3         3         3       3            3           kubernetes.io/os=linux   21h

NAMESPACE     NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
default       deployment.apps/metallb-controller   1/1     1            1           10h
kube-system   deployment.apps/coredns              2/2     2            2           21h

NAMESPACE     NAME                                            DESIRED   CURRENT   READY   AGE
default       replicaset.apps/metallb-controller-748756655f   1         1         1       10h
kube-system   replicaset.apps/coredns-558bd4d5db              2         2         2       21h
