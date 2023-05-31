!SLIDE commandline incremental transition=scrollUp

# Rolling Updates

Tente atualizar o a imagem do nginx nas pods do deploy fe-deployment:

	$ kubectl set image deployment/fe-deployment nginx=nginx:latest -n demo
	deployment.apps/fe-deployment image updated

!SLIDE commandline incremental transition=scrollUp

# Rolling Updates

Após a execução do rollout, verifique novamente seu deployment:

	$ kubectl rollout status deployment/fe-deployment
	deployment "fe-deployment" successfully rolled out
	_

- Processos de rollout dentro de um deployment são acionados quando informações dentro do template da pod são alteradas;

- Outra opção para executar essa alteração seria editar o deployment com o ***"kubectl edit"***; 

- Também é possível editar o arquivo YAML e utilizar o ***"kubectl apply -f"*** para aplicar a alteração;

!SLIDE commandline incremental transition=scrollUp

# Rolling Updates ( Replicaset )

Ao executar um rollout o kuberntes cria uma nova versão do deploy para substituir o deploy anterior, esse versionamento é feito através das replicasets:

	$ kubectl get replicaset -n demo


.callout.info `O novo conjunto de réplicas foi expandido até satisfazer a condição de 2 réplicas rodando conforme fora especificado no deploy`.

!SLIDE transition=scrollUp

# Rolling Updates

***Como fica a disponibilidade durante o deploy?***

Durante o rolout de um deploy o controlador garante que apenas um certo número de pods seja indisponibilizada simultâneamente;`

Esse numero é determinado com base em 2 campos:

- **"maxSurge:"** Numero máximo de pods em processo de criação;
- **"maxUnavailable:"** Numero máximo de pods indisponíveis;

Na execução anterior o controlador criou uma nova Pod, para só então apagar pods da versão anterior respeitando a disponibilidade estabelecida`

.callout.info `Quando não declaramos valores explicitos para a estratégia de deployment o valor "1" é definido como padrão para ambos os campos`