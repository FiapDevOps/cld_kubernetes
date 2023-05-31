!SLIDE center transition=scrollUp

# Resources
![kubernetes](images/kubernetes.png)

!SLIDE transition=scrollUp

# Resources

- No Kubernetes é possível estabelecer limites de uso para quantidade de CPU e Memória que cada namespace pode consumir;

- Dentro do namespace fica a cargo do time definir como seus recursos serão distirbuidos entre suas pods e containers;

- É possível determinar limites específicos por pods e por containers a fim de garantir que um componente ou micro-serviço dentro do cluster não consuma todo o recurso disponível;

.callout.info `No sandbox, as pods são executadas com valores ilimitados para uso de CPU e memória, o mesmo vale para os namespaces;`

.callout.warning `No ambiente de Desenvolvimento e Produção existirá uma quota de recursos por namepsace;`


!SLIDE commandline incremental  transition=scrollUp

# Especificando Limites sobre Containers

Para testar o recurso aplique quotas usando o arquivo [quotas.yaml](https://stash.uol.intranet/projects/PAEIK/repos/kube-class/browse/_files/quotas.yaml);

	$ kubectl apply -f quotas.yaml
        resourcequota "compute-resources" created

Verifique se a alteração foi aplicada:

	$ kubectl describe namespace <SEU-NAMESPACE>
	Name:		<SEU-NAMESPACE>
        ...

	Resource Quotas
 	Name:				compute-resources
 	Resource			Used	Hard
 	--------			---		---
 	configmaps			1		5
 	limits.cpu			0		1
 	limits.memory		0		2Gi

.download quotas.yaml

!SLIDE commandline incremental transition=scrollUp

# Especificando Limites sobre Containers

Uma vez que a configuração de Limits tenha sido aplicada ***O kubernetes não admitirá que pods sejam criadas sem limitações de resources***

Faça uma validação deste conceito tentando executar a recriação do Deployment:

	$ kubectl delete deploy frontend --now
	deployment "frontend" deleted

	$ kubectl apply -f frontend-deployment-cm.yaml --record
        deployment "frontend" created
        service "frontend" configured

        $ kubectl get pods -l tier=FE
        No resources found.

!SLIDE commandline incremental transition=scrollUp

# Especificando Limites sobre Containers

Verifique o status a partir do resource deploy:

    $ kubectl get deploy
    NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    frontend   2         0         0            0           39s
    hello      2         2         2            2           8m

O erro poderá ser apurado verificando a replicaset do deploy:

    $ kubectl describe rs frontend

.callout.info `A definição de limites de recursos será pŕe-requisito para novos componentes entrem nos ambientes development e production, ou seja, sem especificação desses valores o kubernetes não criará o recurso desejado`

!SLIDE transition=scrollUp

# Requests vs Limits

Ao especificar Resources dois tipo de campos podem ser definidos:

- Limits
- Request

Valores do tipo ***"Request"*** referem-se ao chamado recurso garantido, são automaticamente alocados ao container no momento de sua criação;

Valores do tipo ***"Limits"*** referem-se a overcommit ou seja, serão alocados se disponível dentro da quota do namespace;

A alocação dos recursos definidos como overcommit não é automatica, ela ocorre quando um determinado processo requerer uso de mais CPU e/ou mais memória para o container;


!SLIDE transition=scrollUp

# Especificando Limites sobre Containers

Consumo de recursos de Memória e CPU são declarados como Resources dentro da spec do container:

    @@@shell
    ...
    image: nginx:1.10
        ports:
        - containerPort: 80
        resources:
         limits:
           cpu: 200m
           memory: 600Mi
         requests:
           cpu: 100m
           memory: 300Mi

O arquivo [frontend-deployment-limits.yaml](https://stash.uol.intranet/projects/PAEIK/repos/kube-class/browse/_files/frontend-deployment-limits.yaml) contém um exemplo de implementação usando Limits estabelecidos para Memória e CPU;

.download frontend-deployment-limits.yaml


!SLIDE commandline incremental transition=scrollUp

# Utilizando Resources

Refaça o deploymment usando o arquivo [frontend-deployment-limits.yaml](https://stash.uol.intranet/projects/PAEIK/repos/kube-class/browse/_files/frontend-deployment-limits.yaml).

    $ kubectl delete deploy frontend --now
    deployment "frontend" deleted

    $ kubectl apply -f frontend-deployment-limits.yaml --record
    deployment "frontend" created
    service "frontend" configured



!SLIDE commandline incremental transition=scrollUp

# Utilizando Resources

Verifique se o processo de criação ocorreu conforme esperado:

    $ kubectl get deploy,pods -l tier=FE
    NAME              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    deploy/frontend   2         2         2            2           26s

    NAME                          READY     STATUS    RESTARTS   AGE
    po/frontend-296210404-jwr1k   1/1       Running   0          26s
    po/frontend-296210404-wr1kw   1/1       Running   0          26s


!SLIDE transition=scrollUp

# Utilizando Resources

***Importnate:***

.callout.info `Se na especificação de um container os valores de "Request" forem omitidos os valores de "Limits" serão utilizados;`

.callout.info `Um container pode ultrapassar os valores de "Request" desde que ainda esteja dentro dos valores de "Limits" especificados;`

.callout.warning `Se um container ou pod usa mais recursos do que os valores especificados nos "limits", o kubernetes pode encerra-lo;`

.callout.question ***Qual a cota aplicada?*** `Verifique estes valores com o time de SRE ( l-pd-kubenetes ), apesar de existir um valor default cada caso pode ser tratado individulamente de acordo com as necessidades do projeto` 
