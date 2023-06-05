!SLIDE transition=scrollUp

# Secrets

- Objetos do tipo [Secret](https://kubernetes.io/docs/concepts/configuration/secret/) foram criados para permitir o armazenamento de informações sensíveis dentro do cluster, como por exemplos senhas, tokens de acesso OAUTH ou chaves seguras.  

- O objetivo é evitar que esse perfil de informações seja incluso diretamente na Pod ou na imagem do container, na implementação do Ingress utilizamos um secret para armazenar o certificado e a chave de criptografia;

!SLIDE transition=scrollUp

# Secrets

![kubernetes](images/secret-slide.png)
