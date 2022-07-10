# Deploy:

kubectl apply -f .\devops\k8s\rabbitmq.yaml

kubectl apply -f .\devops\k8s\net-rabbitmq-api.yaml

# Restart:

kubectl rollout restart deployment rabbitmq-depl.yaml

kubectl rollout restart deployment net-rabbitmq-api-depl.yaml

# Important:

If you wish to go back and use docker-compose remove both deplyoments and services

kubectl delete deployment net-rabbitmq-api-depl
kubectl delete deployment rabbitmq-depl

kubectl get services
kubectl delete service net-rabbitmq-api-clusterip-srv
kubectl delete service net-rabbitmq-api-loadbalancer
kubectl delete service rabbitmq-clusterip-srv
kubectl delete service rabbitmq-loadbalancer