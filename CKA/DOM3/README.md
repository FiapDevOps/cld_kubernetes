# 1. Exposição de services:

# 2. Ingress Resources:

Para a certificação CKA dentro do uso de recursos de Network e Services deveram surgir questões quanto configuração de uso de [Ingress Resources](https://kubernetes.io/docs/concepts/services-networking/ingress/) no Kubernetes para a exposição de aplicações dentro do cluster;

2.1 Processo de Instalação simples usando o helm:

```sh
helm search hub ingress-nginx -o yaml | head -8
```
> Provavelmente o primeiro repositório no output será o reposiótio oficial do Ingress;

2.2. Faça a instalação do repositório:

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

2.2. Instale o chart necessário:

```sh
helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-controller \
    --create-namespace

kubectl get po,svc -n ingress-controller
```

> No processo de instalação um exemplo de estrutura para criação de um resource do tipo ingress é apresentado no output, você pode utilizar este exemplo ou referências da documentação oficial do Kubernetes;

2.3. Para validar cire um deploy e esponha usando um service:

```sh
kubectl create deployment webserver --image=httpd:latest -n default --replicas=2 
kubectl expose deployment webserver -n default --name test-webserver --port=80
```

2.4. Para criar um recurso do tipo ingress execute:

```sh
kubectl create ingress test-webserver \
    --rule="foo.bar.com/=test:80" \
    --class=nginx -n default
```

2.5. Identifique o end ip do ingress e utilize para validar a sua entrega:

```sh
kubectl get svc ingress-nginx-controller  -n ingress-controller 
export EDGE=$(kubectl get svc ingress-nginx-controller  -n ingress-controller -o jsonpath='{.spec.clusterIP}')
```

2.6. Faça uma chamada http na aplicação para validar o funcionamento:

```sh
curl -H 'Host: foo.bar.com' http://$EDGE
<html><body><h1>It works!</h1></body></html>
```

> Neste exemplo utilizamos o endereço do Cluster IP mas em um cloud provider devidamente configurado por padrão essa instalação via helm construirá um LoadBalancer público quando execute em um Cloud Provider.