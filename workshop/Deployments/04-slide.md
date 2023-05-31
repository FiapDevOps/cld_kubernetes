!SLIDE transition=scrollUp

# Liveness Probes

O kubelet utiliza os recursos liveness e readiness probes para determinar quando reiniciar um Container.

Uma regra de liveness probe bem configurada pode por exemplo identificar um deadlock em uma aplicação em execução e reiniciar o container a fim de tentar garantir a disponíbilidade da aplicação apesar dos bugs.

O exemplo abaixo obtido na [documentação do kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-http-request) demonstra uma regra de liveness probe em uma validação a partir de um endpoint:

    @@@shell
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
        httpHeaders:
        - name: Custom-Header
          value: Awesome

.download http-liveness.yaml

!SLIDE transition=scrollUp

# Liveness Probes

- O campo ***periodSeconds*** especifica que o kubelet deverá performar uma checagem a cada 300 segundos;

- O campo ***initialDelaySeconds:*** especifica que o kubelet deverá aguardar 30 segundos antes de especificar a primeira checagem;

- Se a path "/" no container de destino da chacagem retornar um código de êxito e o header solicitado o kubelet considera o Container como "healthy";

!SLIDE transition=scrollUp

# Liveness Probes

O Processo de checagem também pode ser executado com base na execução de comandos onde o retorno esperado será sempre 0:

    @@@shell
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5

.download exec-liveness.yaml

!SLIDE transition=scrollUp

# Readiness Probes

- Existiram casos em que a aplicação poderá requerer algum tempo para se tornar disponível, por exemplo no carregamento de certo volume de dados ou durante sua inicialização;

- Nesses casos é possível utilizar regras de Readiness Probe para garantir que as requisições só sejam enviadas a aplicação quando esta estiver disponível;

O processo de configuração é o mesmo de uma regra de Liveness Probe:

    @@@shell
    readinessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 20

.callout.info `Neste exemplo a regra aplicada refere-se a checagem TCP o mesmo tipo de regra poderia ser usada no Liveness Probe`

!SLIDE  transition=scrollUp

# Liveness e Readiness Probes

É possível especificar ***Thresholds*** determinando o numero minimo de falhas ou sucessos consecutivos antes que uma ação seja tomada:

- ***successThreshold:*** Numero mínimo de sucessos consecutivos para que a checagem entre em status "successful", caso não declarado o padão para este valor é 1; 

- ***failureThreshold:*** Numero mínimo de falhas consecutivas para que a checagem entre em status "failed", Caso não declarado o padão para este valor é 3, O valor mínimo é 1; 