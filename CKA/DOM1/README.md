1. Processo de backup do ETCD:

Para configurações que exigem criptografia (caso dos setups entregues na CKA) identifique a chave, o certificado e a ca do cluster para executar ações usando o etcdctl;

1.1. Comando para verificação de saúde:

```sh
ETCDCTL_API=3 etcdctl --endpoints https://X.X.X.X:2379 \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    endpoint status
```

> As paths acima foram baseadas na instalação padrão via kubeadm, mas serão passadas paa a execução da prova;

A principal ação quanto ao ETCD será as operações de criação e restauração de snapshots:

1.2. Para criação de um snapshot seguindo a path descrita acima:

```sh
ETCDCTL_API=3 etcdctl --endpoints https://X.X.X.X:2379 \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    snapshot save /tmp/etcd.snapshot
```

1.3. O snapshot pode ser validado executando o comando:

```sh
ETCDCTL_API=3 etcdctl --endpoints https://X.X.X.X:2379 \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    snapshot status /tmp/etcd.snapshot
```

> Aidicione o parâmetro "--write-out=table" para obter uma saída resumida;

Documentação oficial de Ref.: [https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/);