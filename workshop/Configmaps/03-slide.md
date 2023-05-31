!SLIDE transition=scrollUp

# Consumindo ConfigMap nas pods

- A configuração criada via Configmap é entregue a POD como um [Volume](https://kubernetes.io/docs/concepts/storage/volumes/);

- O volume entre a POD é montado dentro do container escolhido como um VolumeMount conforme [Neste Exemplo](https://kubernetes.io/docs/concepts/storage/volumes/#example-pod);

- Com este modelo criaremos uma regra de proxy para que as pods de Frontend entreguem a requisição no serviço "backend";

!SLIDE commandline incremental transition=scrollUp

# Consumindo ConfigMap nas pods

Faça um novo teste com uma chamada ao serviço frontend, ou seja, forçando as requisições pela pod de nginx até o backend:

	$ kubectl exec -ti toolbox -n default curl frontend.demo

.callout.info `Na configuração anterior o valor "mountPath: /etc/nginx/conf.d" especifica a montagem desta path a partir da configuração entregue via ConfigMap, ou seja, todo o conteudo deste diretório será subtituido pelo conteúdo entregue via ConfigMap`

!SLIDE transition=scrollUp

# Consumindo ConfigMap nas pods

- Na configuração atual qualquer conteúdo dentro do diretório "/etc/nginx/conf.d/" será subtituido pelo conteúdo entregue pelo volume montado na configuração do deployment.

- Utilizando o parâmetro sub-path podemos entregar somente um arquivo ao invés de substituir todo o conteúdo do diretório, verifique a [documentação do projeto](https://kubernetes.io/docs/concepts/storage/volumes/#using-subpath) para entender esse contexto;