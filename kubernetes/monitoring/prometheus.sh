helm init
helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/
helm install coreos/prometheus-operator --name prometheus-operator --namespace monitoring
helm install coreos/kube-prometheus --name kube-prometheus --set global.rbacEnable=true --namespace monitoring

# Prometheus proxy
# kubectl port-forward -n monitoring prometheus-kube-prometheus-0 9090
# open http://localhost:9090

# Grafana proxy
# kubectl port-forward $(kubectl get  pods --selector=app=kube-prometheus-grafana -n  monitoring --output=jsonpath="{.items..metadata.name}") -n monitoring  3000
# open http://localhost:3000

# Alertmanager proxy
# kubectl port-forward -n monitoring alertmanager-kube-prometheus-0 9093
# open http://localhost:9093
