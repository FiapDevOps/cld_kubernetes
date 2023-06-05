# Instalação do Ingress Controller

Utilizaremos o helm como ferramenta para instalar o Ingresso Controller default do Kubernetes:

	$ helm upgrade --install ingress-nginx ingress-nginx \
        --repo https://kubernetes.github.io/ingress-nginx \
        --namespace ingress-nginx \
        --create-namespace

Após a instalação aguarde até a pod do controller esteja em execução:

    $ kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=120s

!SLIDE commandline incremental transition=scrollUp

# Criando um recurso para exposição via Ingress

Utilize a command line para criar um novo deployment: 

	$ kubectl create deployment demo --image=httpd --port=80
    deployment.apps/demo created

Crie um serviço interno que será exposto via Ingress ao invés de através de um LoadBalancer:

    $ kubectl expose deployment demo --name=backend
    service/backend exposed

!SLIDE commandline incremental transition=scrollUp

# Criando um recurso para exposição via Ingress

Crie um recurso do tipo ingress via command line:

    $ kubectl create ingress test \
        --class=nginx \
        --save-config \
        --rule="foo.bar.com/*=backend:80"
    ingress.networking.k8s.io/test created

!SLIDE commandline incremental transition=scrollUp

# Criando um recurso para exposição via Ingress

Para validar identifique o endereço de endpoint do serviço de ingress controller:

    $ kubectl get svc ingress-nginx-controller \
        -n ingress-nginx -o json

    $ INGRESS=$(kubectl get svc ingress-nginx-controller \
        -n ingress-nginx -o json | \
        jq -r '.status.loadBalancer.ingress[].hostname')

Utilize o endereço para forjar uma requisição http utilizando o header de Host foo.bar.com:

    $ curl -H 'Host: foo.bar.com' http://$INGRESS
    <html><body><h1>It works!</h1></body></html>