!SLIDE center transition=scrollUp

# Alternativas ao uso de deployments
![kubernetes](images/kubernetes.png)

!SLIDE commandline incremental transition=scrollUp

# Deamonset

No Kubernetes uma estrutura de [deamonset](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) pode ser aplicada para criar um conjunto de pods em todos os nodes do cluster, como em noss configuração do calico como componente de rede do cluster:

Com base nessas labels temos sub-grupos de pods que podem ser acessadas e referenciadas isoladamente:

	$ kubectl get daemonset -n kube-system
	NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
	calico-node   3         3         3       3            3           kubernetes.io/os=linux   41h
	kube-proxy    3         3         3       3            3           kubernetes.io/os=linux   41h

.callout.info `O outro deamonset entregue em nosso cluster criado via kubeadm é o kube-proxy responsável por rotear as requisições entre os containers a partir das chamadas que fizemos aos services do tipo ClusterIP`

!SLIDE transition=scrollUp

# Statefulset

- A estrutura é similar a de um deployment, porém ao contrário de um deployment, um [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) mantém uma identidade fixa para cada um de seus pods. 

- Esses pods são criadas a partir da mesma especificação, mas não são intercambiáveis: cada uma tem um identificador unico o que geralmente é usado em cenários onde queremos anexar volumes persistentes as pods.