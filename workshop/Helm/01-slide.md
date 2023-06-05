!SLIDE center transition=scrollUp

# Utilizando o Helm como package manager

![argocd](images/helm.png)

!SLIDE commandline incremental transition=scrollUp

# Instalação do Helm

Nossa ide possui o Helm instalado, verifique se o binário está disponível:

	$ helm version
    version.BuildInfo{Version:"v3.12.0", ...

Caso necessário o processo de instalação pode ser consultado neste endereço:[https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/);

!SLIDE commandline incremental transition=scrollUp

# Entregando aplicações via Helm

Adicione o repositório **stable** para que tenhamos algo para começar:

	$ helm repo add stable https://charts.helm.sh/stable

Após a instalação é possível listar quais charts podem ser implatados a partir deste repo:

    $ helm search repo stable

.callout.info `O Helm utiliza um sistema de repositórios chamado Charts como fonte para empacotar e entregar apps;`

.callout.info `Os repositórios de Charts são semelhantes aos repositórios APT ou yum com os quais você pode estar familiarizado no Linux ou mesmo Taps for Homebrew no macOS`

!SLIDE commandline incremental transition=scrollUp

# Entregando aplicações via Helm

Faça uma busca por charts para entrega do Nginx como deployment em nosso ambiente kubernetes:

	$ helm search repo nginx
    stable/nginx-ingress                            1.41.3 ...
    stable/nginx-ldapauth-proxy                     0.1.6 ...
    stable/nginx-lego                               0.3.1 ...


Em seguida adicione um novo repositório de Charts:

    $ helm repo add bitnami https://charts.bitnami.com/bitnami

Faça uma busca direcionada com base no repositótio adicionado:

	$ helm search repo bitnami

!SLIDE commandline incremental transition=scrollUp

# Entregando aplicações via Helm

Localize a versão de Chart do nginx entregue pela bitnami:

    $ helm search repo bitnami/nginx

Utilize o Helm para fazer o deployment desta versão:

    $ helm install webserver bitnami/nginx \
        --create-namespace --namespace webapp

Aguarde dois minutos e verifique a criação do deployment e dos recursos:

    $ kubectl get deploy,po,svc -n webapp

.callout.warning `Para acessar a URL do deployment verique que a aplicação roda na porta 80 poranto o endereço de LoadBalancer deve ser apenas usando http:// como prefixo`

!SLIDE commandline incremental transition=scrollUp

# Entregando aplicações via Helm

Para verificar a app criada utilize o seguinte comando:

    $ helm list --namespace webapp

Finalmente para o processo de remocação do recurso execute:

    $ helm uninstall webserver --namespace webapp