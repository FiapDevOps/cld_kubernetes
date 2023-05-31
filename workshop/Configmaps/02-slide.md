!SLIDE commandline incremental transition=scrollUp

# Consumindo ConfigMap nas pods

Usaremos o arquivo [be-deployment.yaml](URL) para criar um deploy que atuará como backend dessa aplicação:

	$ kubectl -n demo apply \
		-f URL 
	ddeployment.apps/be-deployment created
	service/backend created

Faça um teste com uma chamada ao serviço criado:

	$ kubectl exec -ti toolbox -n default curl backend.demo

.download be-deployment.yaml
.download fe-deployment-proxy.yaml

!SLIDE commandline incremental transition=scrollUp

# Consumindo ConfigMap nas pods

Em seguida ajuste o deploy fe-deployment para que consuma e expanda a configuração entregue via configmap, para isso substitua a versão anterior pela versão fe-deployment-proxy:

	$ kubectl apply -n demo apply \
		-f URL

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
