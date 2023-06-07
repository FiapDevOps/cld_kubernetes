!SLIDE center transition=scrollUp

# Implementando uma solução de CD

![argocd](images/argocd.png)

!SLIDE commandline incremental transition=scrollUp

# Instalação do Argo CD

Os componentes necessários para o ArgoCD podem ser instalados usando um manifesto fornecido pelo Projeto:

	$ kubectl create namespace argocd
	$ kubectl apply -n argocd -f <URL>

URL que será usada no comando:

[Copie a URL aqui](https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml)


!SLIDE commandline incremental transition=scrollUp

# Instalação do Argo CD

Por padrão, o argocd-server não é exposto publicamente, Para o objetivo deste workshop, usaremos um Load Balancer para torná-lo acessível:

	$ kubectl patch svc argocd-server \
		-n argocd -p '{"spec": {"type": "LoadBalancer"}}'

Espere 2 minutos até que o serviço esteja publicado e identifique o endereço público atribuido:

	$ export ARGOCD_SERVER=`kubectl get svc argocd-server \
		-n argocd -o json | \
		jq --raw-output '.status loadBalancer.ingress[0].hostname'`

Acesse em um navegador a URL do endereço de loadbalancer:

	$ echo $ARGOCD_SERVER

!SLIDE commandline incremental transition=scrollUp

# Instalação do Argo CD

A senha gerada no bootstrap inicial do argo foi armazenada em um recurso do tipo [Secret](https://kubernetes.io/docs/concepts/configuration/secret/), recupere esses dados usando o kubectl:

	$ export ARGO_PWD=`kubectl -n argocd get secret \
		argocd-initial-admin-secret \
		-o jsonpath="{.data.password}" | base64 -d`

Utilize esse senha para acessar o Argo na UI aberta e acessível atra'ves do LoadBalancer criado anteriormente, neste acesso **utilize o usuário admin**

	$ echo $ARGO_PWD