!SLIDE commandline incremental transition=scrollUp

# Criação do Namespace

É possível usar namespaces para limita recursos e controle de acessos.

	$ kubectl get namespaces
	NAME              STATUS   AGE
	default           Active   37h
	demo              Active   5m17s
	kube-node-lease   Active   37h
	...

.callout.question `É comum que a criação de namespace seja restrita e governada já que é nesse escopo que definimos limitações sobre o uso de recursos, poderiamos por exemplo estruturar modelos de organização distribuindo namespace por times ou projetos.`


!SLIDE commandline incremental transition=scrollUp

# Criação do Namespace

Os namespaces são acessados a partir da flag "-n" ou "--namespace" ao executar um comando do Kubernetes:

	$ kubectl get service --namespace default
	NAME         TYPE        CLUSTER-IP   EXTERNAL-IP
	kubernetes   ClusterIP   10.96.0.1    <none>     

	$ kubectl get svc -n kube-system
	NAME       TYPE        CLUSTER-IP   EXTERNAL-IP               
	kube-dns   ClusterIP   10.96.0.10   <none>        

.callout.info `A maioria dos comandos de kubernetes possuem parâmetros que podem ser passados de forma contraida como --namespace = -n`

!SLIDE commandline incremental transition=scrollUp

# Criação do Namespace

Para manipoular multiplos namespaces e credenciais pode-se criar contextos:

	$ kubectl config get-contexts
	*          kubernetes-admin@kubernetes   kubernetes   ...

	$ kubectl config view
	apiVersion: v1
	clusters:
	- cluster:
 	   certificate-authority-data: DATA+OMITTED       
	...

!SLIDE commandline incremental transition=scrollUp

# Criação do Namespace

Crie um novo contexto para validar o processo de troca entre namespaces:

	$ kubectl config set-context kubernetes-demo \
		--kubeconfig=$HOME/.kube/config \
		--cluster=kubernetes \
		--user=kubernetes-admin \
		--namespace=demo
	Context "kubernetes-demo" created.

.callout.info `Cada contexto recebe parametrôs de identificação do namespace a ser acessado ao omitir a flag -n e de autenticação e cluster configurado, além do caminho para o arquivo de credenciais passado via flag --kubeconfig`


!SLIDE commandline incremental transition=scrollUp

# Criação do Namespace

Após isso acesse o contexto kubernetes-demo:

	$ kubectl config use-context kubernetes-demo
	Switched to context "kubernetes-demo".

	$ kubectl get all	
	No resources found in demo namespace.

Volte ao contexto kubernetes-admin@kubernetes:

	$ kubectl config use-context kubernetes-admin@kubernetes
	Switched to context "kubernetes-admin@kubernetes".