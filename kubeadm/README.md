```sh
export IPADDR=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
export NODENAME=$(hostname -s)
export POD_CIDR="192.168.0.0/16"
```

```sh
rm -rf /etc/containerd/config.toml && systemctl restart containerd

sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=$POD_CIDR --node-name $NODENAME --ignore-preflight-errors Swap
```

Documentação de ref: [https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

```sh
sudo su -
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Execute o join dos nodes remanecentes:
```sh
kubeadm join 172.31.X.X:6443 --token XXXXXXXXXXX --discovery-token-ca-cert-hash sha256:XXXXXXXXXX
```

> Se for necessário a partir do control plane é posível recuperar o comando de join:
```sh
kubeadm token create --print-join-command
```

Configure um mecanismo de CNI:
```sh
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
```

Crie um workload inicial para revalidar o processo:
```sh
kubectl -n default apply -f https://k8s.io/examples/application/deployment.yaml
```

Verifique a criação das pods e distribuição:
```sh
kubectl get po -n default -o wide
```