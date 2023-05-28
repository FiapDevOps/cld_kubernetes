Para iniciar a construção de nosso primeiro ambiente faça a implantação das instâncias que farão a composição do cluster:

```sh
cd ~/environment/kube-class/kubeadm
terraform init
terraform apply
```

Recupere a chave gerada via Terraform que foi armazenada como estado local:

```sh
terraform output -raw private_key > $HOME/.ssh/id_rsa && chmod 600 $HOME/.ssh/id_rsa
```

Aguarde até que a instância esteja criada, em seguida ddentifique a instancia que será usada como controlplane:
```sh
export CONTROLPLANE=$(
    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=controlplane" \
        --query "Reservations[*].Instances[*].PrivateIpAddress" --output text
)

echo $CONTROLPLANE
```

Faça o acesso via SSH:

```sh 
ssh -l ubuntu $CONTROLPLANE
```

Dentro da insância crie as variaveis que serão utilizadas com o kubeadm na inicialização do control plane:

```sh
export IPADDR=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
export NODENAME=$(hostname -s)
export POD_CIDR="192.168.0.0/16"
```

Remova a configuração atual do containerd e em seguida reinicie po serviço:
```sh
sudo rm -rf /etc/containerd/config.toml && sudo systemctl restart containerd
```

Inicie o kubeadm utilizando as variaveis criadas anteriormente:
```sh
sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=$POD_CIDR --node-name $NODENAME --ignore-preflight-errors Swap
```

Documentação de ref: [https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

Após a inicialização ajuste as variaveis de sua home de usuário conforme para acessar o cluster kubectl:
```sh
sudo su -
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Valide o funcionamento do cluster executando uma consulta via kubectl:
```sh
kubectl get po -n kube-system
```

Para executar o ingresso dos nodes remanecentes, é necessário um comando no kubeadm, conforme exemplo abaixo:
```sh
kubeadm join 172.X.X.X:6443 --token YYYYYYYYYYY \
        --discovery-token-ca-cert-hash sha256:6d3a43941c..... 
```

Para facilitar a tarefa execute a seguinte sequência criando uma variavel com o comando de join:

```sh
exit
JOIN_CMD=$(ssh -l ubuntu $CONTROLPLANE  sudo kubeadm token create --print-join-command)
echo $JOIN_CMD
```

```sh
export WORKERS=$(
    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=worker" \
        --query "Reservations[*].Instances[*].PrivateIpAddress" --output text
)

echo $WORKERS
```

Execute o join dos dois workers ao cluster:
```sh
for HOST in $(echo $WORKERS); do \
    ssh -l ubuntu $HOST -o StrictHostKeyChecking=no \
    "sudo rm -rf /etc/containerd/config.toml && sudo systemctl restart containerd && sudo $JOIN_CMD"; \
    done
```

Acessando novamente o controlplane verifique o status dos nodes adicionados:

```sh
kubectl get nodes
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

---

##### Fiap - MBA
profhelder.pereira@fiap.com.br

**Free Software, Hell Yeah!**