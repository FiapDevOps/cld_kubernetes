
#!/bin/bash

# ==============================================================================================================================

resize () {
# Resizing para o disco local do ambiente:
sh $HOME/environment/kube-class/cloud9/scripts/resize.sh 20 > /dev/null
}

configure_deps () {

test -d $HOME/environment/info || install -d -m 0700 -o $(whoami) -g $(whoami) $HOME/environment/info

# Identificando o end pub da instancia:
curl -s http://169.254.169.254/latest/meta-data/public-ipv4 -o $HOME/environment/info/PUBLIC_IP.txt && chown ec2-user: $HOME/environment/info/PUBLIC_IP.txt
curl -s http://169.254.169.254/latest/meta-data/public-hostname -o $HOME/environment/info/PUBLIC_DNS.txt && chown ec2-user: $HOME/environment/info/PUBLIC_DNS.txt

# Instalação de componentes:
printf "\n Configurando Dependencias \n"
sudo yum install -y tmux jq

printf "\n Instalando o docker-compose \n"
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Download e instalação do kubectl
printf "\n Instalando o cliente do Kubernetes \n"
sudo curl --silent --location -o /usr/local/bin/kubectl    https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.17/2023-05-11/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl

# Download e instalação do eksctl
printf "\n Instalando o cliente eksctl \n"
sudo curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin

# Download e instalação do helm # https://helm.sh/docs/intro/install/
printf "\n Instalando o helm \n"
sudo curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod +x /tmp/get_helm.sh
sudo /tmp/get_helm.sh

printf "\n Gravando alterações no .bashrc \n"
echo "export AWS_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)" >> $HOME/.bashrc

}

configure_access () {

printf "Identificando o SecurityGroup do projeto"
aws ec2 describe-security-groups --filters Name=group-name,Values=*aws-cloud9* --query "SecurityGroups[*].[GroupName]" --output table

# Definindo o SECURITY GROUP atual
CURRENT_SG=$(aws ec2 describe-security-groups --filters Name=group-name,Values=*$C9_PID* --query "SecurityGroups[*].[GroupId]" --output text)
EKS_SG=$(aws ec2 describe-security-groups --filters Name=group-name,Values=*eks-cluster* --query "SecurityGroups[*].[GroupId]" --output text)

aws ec2 authorize-security-group-ingress --group-id $EKS_SG --protocol tcp --port 0-65535 --source-group $CURRENT_SG
aws ec2 authorize-security-group-ingress --group-id $EKS_SG --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $EKS_SG --protocol tcp --port 8443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $CURRENT_SG --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $CURRENT_SG --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $CURRENT_SG --protocol tcp --port 8080 --cidr 0.0.0.0/
}

# ==============================================================================================================================

resize
configure_deps
configure_access

printf "\n Configurando Enviroment Env \n"
bash