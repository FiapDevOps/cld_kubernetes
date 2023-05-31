!SLIDE center transition=scrollUp

# Namespaces

![kubernetes](images/kubernetes.png)

!SLIDE transition=scrollUp

# Criação do Namespace

Para iniciar recuppere o ip do controlplane criado na parte 1 do workshop:

	export CONTROLPLANE=$(
		aws ec2 describe-instances \
        	--filters "Name=tag:Name,Values=controlplane" \
        	--query "Reservations[*].Instances[*].PrivateIpAddress" \
			--output text)
		
	echo $CONTROLPLANE


 Faça o acesso via SSH:

	ssh $CONTROLPLANE

Assuma o perfil root onde estão as credenciais de acesso ao cluster: 

	$ sudo su -

!SLIDE commandline incremental transition=scrollUp


# Criação do Namespace

No Kubernetes temos a possibilidade de agrupar recursos para cada time ou projeto em clusters virtuais chamados de ***namespaces***;

Cada projeto possui um namespace com limitação de recursos e controle de acessos.

	$ kubectl get namespaces
	NAME                      STATUS    AGE
	default           Active   43m
	kube-node-lease   Active   43m
	kube-public       Active   43m
	kube-system       Active   43m


!SLIDE commandline incremental transition=scrollUp

# Criação do Namespace

Crie um namespace para deploy de seus recursos, utilize seu username como nome para o namespace:

	$ kubectl create namespace demo
	namespace/demo created

.callout.info `Na criação do namespace apenas os caracteres que se encaixam na regex [a-z0-9]([-a-z0-9]*[a-z0-9])? (por exemplo: 'uolcs-busca' ou '123-abc'`