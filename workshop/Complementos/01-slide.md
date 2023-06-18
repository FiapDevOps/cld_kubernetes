!SLIDE center transition=scrollUp

# Extras
![kubernetes](images/kubernetes.png)


!SLIDE transition=scrollUp

# Debbuging

- Durante o processo de configuração entrega de deployments no Kubernetes erros de diversos tipos podem ocorrer...

- Esses erros variam desde erro no processo de pull de imagem, configmaps mal mapeados, acls ou inexistência de quotas;

- Encontramos [Neste Link](https://kukulinski.com/10-most-common-reasons-kubernetes-deployments-fail-part-1/) uma boa relação destes erros com base na experiência de quem já andou trabalhando no kubernetes;


!SLIDE transition=scrollUp

# POD Status

PODS em status ***pending*** são basicamente pods que não podem ser alocadas ou ainda estão em processo de alocação em um node, a continuação desse status pode derivar de 'n' fatores, por exemplo, falta de recursos de infra estrutura ou estouro dos limites estabelecidos para o seu namespace;

PODS em status ***waiting*** são pods alocadas em um node que por algum motivo não conseguem ser executadas;

PODS dando erro ***crashing*** podem obter este estado por vários motivos, a maioria deles internos relacionados a execução de tarefas, configuração etc, verificar os logs da pod utilizando algum dos recursos a seguir é uma boa opção para testes e depuração de erros;

.callout.info `Para cada um dos status descritos um primeiro passo útil seria executar um "kubectl describe" diretamente na pod`

!SLIDE transition=scrollUp

# POD Status

Outra categoria de Erros muito comuns são erros relacionados ao pull de imagens do Registry:

- Em situações onde estiver ocorrendo erros no processo de pull de imagem o status ***ErrImagePull*** será apresentado;

- Caso o erro persista o status ser apresentado como ***ImagePullBackOff***;

.callout.warning `Verificar o caminho para imagem do container e as permissões de acesso no Registry pode ser um bom começo`

.callout.info  `Outro processo útil é executar o pull manualmente em seu host utilizando docker, não se esqueça que, caso o repositório seja privado um token de autenticação será necessário para que o kubernetes execute o pull na criação do recurso`

!SLIDE transition=scrollUp

# Verificação de Logs

Dentro das pods é possível verificar logs de containers de forma similar ao processo executado via Docker logs:

	sintaxe:
	$ kubectl logs ${POD_NAME} ${CONTAINER_NAME}

Containers com status "crashing" podem ser verificados utilizando a opção "--previous"

	sintaxe:
	$ kubectl logs --previous ${POD_NAME} ${CONTAINER_NAME}

!SLIDE transition=scrollUp

# Executando Comandos

Em alguns cenários pode ser necessário atuar dentro da Pod, esse processo pode ser executado via "kubectl exec":

	sintaxe:
	$ kubectl exec ${POD_NAME} -c ${CONTAINER_NAME} {COMMAND}

	Exemplo:
	$ kubectl exec frontend-3862423870-rzcfp -it /bin/sh

.callout.info `Substitua o /bin/sh pelo comando a ser executado dentro do container, caso a Pod possua apenas um container a opção -c ${CONTAINERNAME} pode ser omitida`


!SLIDE transition=scrollUp

# Depuração de Eventos

Ao executar Deployments, ou executar quaisquer outras manipulações nos resources são gerados Eventos esses dados são persistidos no etcd e fornecem informações de alto nível sobre o que está acontecendo no cluster.

Para visualizar eventos relacionados a recursos utilize a função "describe":

	$ kubectl describe pod frontend-3862423870-rzcfp

	$ kubectl describe deploy frontend
