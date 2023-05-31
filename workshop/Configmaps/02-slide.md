!SLIDE commandline incremental transition=scrollUp

# Consumindo ConfigMap nas pods

Usaremos o arquivo [be-deployment.yaml](https://raw.githubusercontent.com/fiapdevops/kube-class/main/workshop/_files/share/be-deployment.yaml) para criar um deploy que atuará como backend dessa aplicação:

	$ kubectl -n demo apply -f be-deployment.yaml 
	ddeployment.apps/be-deployment created
	service/backend created

URL usada no comando: https://raw.githubusercontent.com/fiapdevops/kube-class/main/workshop/_files/share/be-deployment.yaml  

Faça um teste com uma chamada ao serviço criado:

	$ kubectl exec -ti toolbox -n default curl backend.demo

.download be-deployment.yaml
.download fe-deployment-proxy.yaml

!SLIDE commandline incremental transition=scrollUp

# Consumindo ConfigMap nas pods

Em seguida ajuste o deploy fe-deployment para que consuma e expanda a configuração entregue via configmap, para isso substitua a versão anterior pela versão [fe-deployment-proxy](https://raw.githubusercontent.com/fiapdevops/kube-class/main/workshop/_files/share/fe-deployment-proxy.yaml):

	$ kubectl apply -n demo apply -f fe-deployment-proxy.yaml

URL usada no comando: https://raw.githubusercontent.com/fiapdevops/kube-class/main/workshop/_files/share/fe-deployment-proxy.yaml

.callout.info `Neste caso substituimos o arquivo mas seria possível embora não recomendado em produção editar diretamente adicionando os campos para montar o volume com o configmap`

!SLIDE transition=scrollUp

# Consumindo ConfigMap nas pods

A nova versão do deployment possui a montagem do volume com o arquivo de configuração do nginx:

    @@@shell
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
          - name: frontend-config
            mountPath: /etc/nginx/conf.d
      volumes:
      - name: frontend-config
        configMap:
          name: frontend-config
