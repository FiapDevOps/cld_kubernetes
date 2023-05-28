# Entrega de um cluster manual configurado usando kubeadm

Documentação de ref: 

- [Criação de cluster via kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/);
- [Instalação do Docker](https://docs.docker.com/engine/install/ubuntu/);
- [Instalação do kubelet, kubeadm e kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management);

---

## 1. Criação da infraestrutura usando terraform: 

1.1 Para iniciar a construção de nosso primeiro ambiente faça a implantação das instâncias que farão a composição do cluster:

```sh
cd ~/environment/kube-class/kubeadm
terraform init
terraform apply
```

1.2 Recupere a chave gerada via Terraform que foi armazenada como estado local:

```sh
terraform output -raw private_key > $HOME/.ssh/id_rsa && chmod 600 $HOME/.ssh/id_rsa
```

1.3 Aguarde até que a instância esteja criada, em seguida ddentifique a instancia que será usada como controlplane:
```sh
export CONTROLPLANE=$(
    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=controlplane" \
        --query "Reservations[*].Instances[*].PrivateIpAddress" --output text
)

echo $CONTROLPLANE
```

1.4 Faça o acesso via SSH:

```sh 
ssh -l ubuntu $CONTROLPLANE
```
---

## 2. Inicialização do cluster usando o kubeadm:

2.1 Dentro da insância crie as variaveis que serão utilizadas com o kubeadm na inicialização do control plane:

```sh
export IPADDR=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
export NODENAME=$(hostname -s)
export POD_CIDR="192.168.0.0/16"
```

2.2 Remova a configuração atual do containerd e em seguida reinicie po serviço:
```sh
sudo rm -rf /etc/containerd/config.toml && sudo systemctl restart containerd
```

2.3 Inicie o kubeadm utilizando as variaveis criadas anteriormente:
```sh
sudo kubeadm init --apiserver-advertise-address=$IPADDR \
        --apiserver-cert-extra-sans=$IPADDR  \
        --pod-network-cidr=$POD_CIDR \
        --node-name $NODENAME \
        --ignore-preflight-errors Swap
```

2.4 Após a inicialização ajuste as variaveis de sua home de usuário conforme para acessar o cluster kubectl:
```sh
sudo su -
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

2.5 Valide o funcionamento do cluster executando uma consulta via kubectl:
```sh
kubectl get po -n kube-system
```
---

## 3 Executando o ingresso de novos nodes:

3.1 Para executar o ingresso dos nodes remanecentes, é necessário um comando no kubeadm, conforme exemplo abaixo:
```sh
kubeadm join 172.X.X.X:6443 --token YYYYYYYYYYY \
        --discovery-token-ca-cert-hash sha256:6d3a43941c..... 
```

3.2 Para facilitar abra uma nova guia e execute a seguinte sequência criando uma variavel com o comando de join:

```sh
export CONTROLPLANE=$(
    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=controlplane" \
        --query "Reservations[*].Instances[*].PrivateIpAddress" --output text
)

JOIN_CMD=$(ssh -l ubuntu $CONTROLPLANE  sudo kubeadm token create --print-join-command)

echo $JOIN_CMD
```

> O comando anterior permite recuperar o token que será usado para os workers autenticaram no cluster, e identificar o endereço dos workers;

3.3 Com esse dado em mãos execute o join dos workers no cluster:

```sh
export WORKERS=$(
    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=worker" \
        --query "Reservations[*].Instances[*].PrivateIpAddress" --output text
)

for HOST in $(echo $WORKERS); do \
    ssh -l ubuntu $HOST -o StrictHostKeyChecking=no \
    "sudo rm -rf /etc/containerd/config.toml && sudo systemctl restart containerd && sudo $JOIN_CMD"; \
    done
```

3.4 Acessando novamente a guia logada no controlplane verifique o status dos nodes adicionados:

```sh
kubectl get nodes
```

> Os nodes estão a disposição porém sem um componente atuando como CNI(https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)


3.5 Configure o calico como o nosso mecanismo de CNI usando o comando abaixo:
```sh
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
```

3.6 Aguarde até que as pods estejam em execução e verifique novamente o status do cluster:

```sh
kubectl get nodes
```

---

## 4. Testando o funcionamento do cluster

4.1 Crie um workload inicial para validar o funcionamento do cluster:
```sh
kubectl -n default apply -f https://k8s.io/examples/application/deployment.yaml
```

4.2 Verifique a criação das pods e distribuição:
```sh
kubectl get po -n default -o wide
```

4.3 Crie um serviço com um endpoint para o acesso aos pods:
```sh
kubectl expose deployment nginx-deployment -n default --name=webserver --port=80
```

4.4 Verifique a criação do serviço:
```sh
kubectl describe svc webserver -n default 
```

---

##### Fiap - MBA
profhelder.pereira@fiap.com.br

**Free Software, Hell Yeah!**