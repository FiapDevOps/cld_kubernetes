# Base sobre Limit Ranges, Quotas e Scopes

---

## LimitRange:

- Os recursos do tipo limitrange são baseados em controle de uso de CPU e Memória consumidos tanto pela pod quanto pelos containers:

Exemplo:

```sh
# kubectl create -f examples/namespace.yaml
# kubectl apply -f examples/limitrange/limits.oc.yaml
# kubectl apply -f examples/limitrange/invalid-pod.xyz.yaml
# kubectl describe node
# kubectl describe limits             
```

- O dimensionamento do limitrange deve ser diretamente proporcional ao tamanho dos nodes no cluster, se limitar o limit range de memória para pods em 1Gi, isso quer dizer que nenhuma pod poderá nascer com mais de um 1Gi mas não delimita necessariamente quantas pods deste tamanho podem ser criadas:

### Diferenças entre LimitRange e Quotas:

- LimitRange ***não*** são quotas, quotas baseiam-se no uso de quantidades especificas de recursos, ao delimitar uma quota o usuário será impedido de ultrapassala e será avisado no momento da tentativa de criação do recurso;

```sh
# kubectl create -f examples/quotas/quota-pod-xyz.yaml
# kubectl delete -f examples/limitrange/valid-pod.xyz.yaml
# kubectl create -f examples/limitrange/valid-pod.xyz.yaml
```

Enquanto os limiteranges se aplicam a melhor utilização de recursos no node as quotas se aplicam ao cluster, por isso na definição dos limits considerar a quantidade de pods que o usuário ira criar para estimar os gastos no node, ou limitar com base nas quotas, o que faz muito mais sentido;

### Memory Request x Memory Limits

***Memory Request***

- O campo "default request" define o montante de recursos solicitados e ***DEVERÃO*** ser atribuídos. O scheduler do kubernetes usará essas quantidades para testar a viabilidade do encaixe de uma pod em um nó.

- Se esse campo for omitido para um contêiner, o padrão será limite se for explicitamente especificado, caso contrário, este será sempre 0 ou seja undefined;

***Memory Limits:***

- Com relação ao containers os valores max, min e default de memória e CPU ( Memory e CPU Limits ) definem a quantidade máxima de recursos que serão disponibilizados para um ***container em relação a sua pod ou para uma pod em relação ao nós onde está alocada***;

- Se um container ou pod usa mais recursos do que seu limite, o kubernetes pode encerra-lo.
- O limite padrão é sempre "unbounded";

Exemplo 1: ( Deploy com tamanho OK sem overcomit ) 

```sh
# kubectl apply -f examples/limitrange/limits.oc.reqs.yaml
# kubectl apply -f examples/limitrange/valid-dpl.req.yaml
# kubectl get pods
# kubectl describe node
```

Exemplo 2: ( Deploy com tamanho OK forçando overcomit )

```sh
# kubectl scale deploy valid-dpl --replicas=4
```

Exemplo 3: ( Deploy com request maior que o tamanho do node )

```sh
# kubectl delete -f examples/limitrange/valid-dpl.req.yaml
# kubectl apply -f examples/limitrange/invalid-dpl.req.yaml
# kubectl get pods
# kubectl describe deploy
# kubectl describe node 
```

---

# Comportamentos esperados:

### Importancia dos limites default:

1 - Caso a pod seja criada sem que seja especificado um valor para o "limit" de  memória, o campo "Memory Limits" utilizará o default do LimitRange do NS;

2 - Caso a pod seja criada sem que seja especificado um valor para o "request", o campo Memory Request utilizará o default do campo defaultRequest do LimitRange do ns;

3 - Caso não exista valor para o campo request e nenhum valor defaultRequest o limit será utilizado;

---

# Configuração de scopes:

Os tipos de scopes definem quais as regras de jogo para estabelecer QoS de serviços, o kubernetes faz essa classificação automaticamente com base no tipo de limit e request criado seguindo as seguintes regras:

| **Scope:**       | **Função:**                                                                                                   |
|------------------|---------------------------------------------------------------------------------------------------------------|
| Burstable        | Usado quando requests e limits são especificados, ( Esse segundo é opicional );                               |
| Guaranteed       | Usando quando valores igauis são especificados para request e limits em todos os resources e containers;      |
| Best-Effor       | Usado quando nem requests e nem limits são especificados em um container;                                     |

Exemplos:

## Criação de containers do tipo Burstable:

```sh
# kubectl create -f examples/limitrange/valid-dpl.burstable.yaml
# kubectl describe pod | egrep -w "QoS|Name:"
```

> If requests and optionally limits are set (not equal to 0) for one or more resources across one or more containers, and they are not equal, then the pod is classified as Burstable. When limits are not specified, they default to the node capacity.


## Criação de containers do tipo Guaranteed:

```sh
# kubectl create -f examples/limitrange/valid-dpl.guaranteed.yaml
# ( Se ncessário aumentar as quotas para esse test ), por serem recursos betas deploys não possuem mensagems de erro devidamente configuradas;
# kubectl describe pod | egrep -w "QoS|Name:"
```

> If limits and optionally requests (not equal to 0) are set for all resources across all containers and they are equal, then the pod is classified as Guaranteed.

## Criação de containers do tipo Best-Effort:

```sh
# kubectl delete limits
# kubectl delete quota
# kubectl create -f examples/limitrange/valid-dpl.best-effort.yaml
# kubectl describe pod | egrep -w "QoS|Name:"
```

> If requests and limits are not set for all of the resources, across all containers, then the pod is classified as Best-Effort.

---

# Material de Referencia:

* [The Kubernetes resource model](https://github.com/kubernetes/kubernetes/blob/release-1.1/docs/design/resources.md)

* [Resource Quality of Service in Kubernetes](https://github.com/kubernetes/kubernetes/blob/release-1.1/docs/proposals/resource-qos.md)

* [Openshift Setting Quotas](https://docs.openshift.com/enterprise/3.2/admin_guide/quota.html)

* [Openshift Compute Resources](https://docs.openshift.com/enterprise/3.2/dev_guide/compute_resources.html)

* [Openshift Overcommitting](https://docs.openshift.org/latest/admin_guide/overcommit.html)

* [Giant Swarm Scheduling Constraints and Resource Quality of Service](https://docs.giantswarm.io/guides/scheduling-constraints-and-resource-qos/)
