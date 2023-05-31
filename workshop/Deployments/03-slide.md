!SLIDE commandline incremental transition=scrollUp 

# Rolling Back Deployments

Quando um processo de Rollout é ativado o kubernetes cria um Log de revisão relativo a versão antrerior chamado "Deployment Revision";

Considere o exemplo utilizado no rollout contendo um erro na versão da imagem a ser aplicada, onde ao invés da imagem 1.9.1 aplciaremos a imagem 1.99 ( Que não existe ):

	$ kubectl set image deployment/fe-deployment \
		nginx=nginx:1.99 -n demo
	deployment.apps/fe-deployment image updated

Neste cenário o processo de Deployment ficará travado:

	$ kubectl rollout status deployments fe-deployment -n demo
	Waiting for deployment "fe-deployment" rollout to finish: 1 out ...

( Use o Ctrl + C para cancelar a execução )


!SLIDE commandline incremental transition=scrollUp

# Rolling Back Deployments

Verifique o número de replicas disponíveis e o status das pods:

	$ kubectl get rs -n demo
	NAME                    DESIRED   CURRENT   READY     AGE
	fe-deployment-57cc979f88   1         1         0       64s
	fe-deployment-599bb48c7    0         0         0       9m6s
	fe-deployment-76d8466f5d   2         2         2       8m51s

	$ kubectl get pods -l tier=fe -n demo
	NAME                             READY   STATUS          
	fe-deployment-57cc979f88-vcrfz   0/1     ImagePullBackOff
	fe-deployment-76d8466f5d-4zbvk   1/1     Running          
	fe-deployment-76d8466f5d-kllkh   1/1     Running          


!SLIDE commandline incremental transition=scrollUp

# Rolling Back Deployments

Para corrigir, será necessário reverter o deploy para uma versão anterior:

	$ kubectl rollout history deployment/fe-deployment -n demo
	deployment.apps/fe-deployment 
	REVISION  CHANGE-CAUSE
	1         kubectl create --filename=fe-deployment.yaml ...
	2         kubectl create --filename=fe-deployment.yaml ...
	3         kubectl create --filename=fe-deployment.yaml ...


Verifique o detalhamento técnico de cada revisão usando a sintaxe:

	$ kubectl rollout history deployment/fe-deployment \
		--revision=2 -n demo

!SLIDE commandline incremental transition=scrollUp

# Rolling Back Deployments

Executando o Processo de Rollback para a versão anterior:

	$ kubectl rollout undo deployment/fe-deployment -n demo
	deployment.apps/fe-deployment rolled back

Verifique o status do deployment:

	$ kubectl get deployment -n demo
	NAME            READY   UP-TO-DATE   AVAILABLE   AGE
	fe-deployment   2/2     2            2           12m

Verifique o status das pods:

	$ kubectl get pods -n demo
	NAME                             READY   STATUS    RESTARTS
	fe-deployment-76d8466f5d-4zbvk   1/1     Running   0        
	fe-deployment-76d8466f5d-kllkh   1/1     Running   0        


!SLIDE commandline incremental transition=scrollUp

# Rolling Back Deployments

Outra possibilidade para execução do Rollback é especificar versão a ser aplicada:

	$ kubectl rollout undo deployment/fe-deployment \
		--to-revision=1 -n demo
	deployment.apps/fe-deployment rolled back

	$ kubectl get rs -n demo
	NAME                       DESIRED   CURRENT   READY   AGE
	fe-deployment-57cc979f88   0         0         0       7m24s
	fe-deployment-599bb48c7    2         2         2       15m
	fe-deployment-76d8466f5d   0         0         0       15m

.callout.warning `A Execução de um deployment não cria um "Deployment Revision", considerando que processos de rollout são ativados por alterações dentro do template, logo, durante um processo de rollback apenas as configurações referentes ao template poderão ser recuperadas`

!SLIDE commandline incremental transition=scrollUp

# Scaling Deployments

O kubernetes possui recursos para execução de scale de replicas no deploy:

	$ kubectl scale deployment fe-deployment --replicas=4 -n demo

	$ kubectl get pods -n demo
	NAME                            READY   STATUS    RESTARTS   AGE
	fe-deployment-599bb48c7-2kd56   1/1     Running   0          22s
	fe-deployment-599bb48c7-4h4gz   1/1     Running   0          14m
	fe-deployment-599bb48c7-6vkdk   1/1     Running   0          14m
	...

.callout.warning `No exemplo abaixo estamos executando um scale manual alterando a quantidade de replicas do deployment mas é possível automatizar o processo usando o sistema de auto-scale chamado hpas`

