```sh
sudo su -
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

```sh
```
