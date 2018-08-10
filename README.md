# kops - AWS k8s

## Install kops and kubectl
If you need kops and kubectl run apps.sh

## Install the cluster
To install the cluster run kops.sh

## Set roles and permissions
```
kubectl apply -f ./kubernetes/rbac
```

## Install Dashboard and monitoring [here](https://github.com/aws-samples/aws-workshop-for-kubernetes/tree/master/02-path-working-with-clusters/201-cluster-monitoring)
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl apply -f ./kubernetes/rbac/admin-user.yaml
Proxy: kubectl proxy --address 0.0.0.0 --accept-hosts '.*' --port 8080
Get token:
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

kubectl apply -f ./kubernetes/heapster
```

- proxy: kubectl proxy --address 0.0.0.0 --accept-hosts '.*' --port 8080
  - Dashboard: /api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
  - Grafana: /api/v1/namespaces/kube-system/services/monitoring-grafana/proxy/?orgId=1

- Prometheus proxy
  - kubectl port-forward -n monitoring prometheus-kube-prometheus-0 9090
  - open http://localhost:9090

- Grafana proxy
  - kubectl port-forward $(kubectl get  pods --selector=app=kube-prometheus-grafana -n  monitoring --output=jsonpath="{.items..metadata.name}") -n monitoring  3000
   - open http://localhost:3000

- Alertmanager proxy
  - kubectl port-forward -n monitoring alertmanager-kube-prometheus-0 9093
  - open http://localhost:9093

## Set env vars
Make sure to set CLUSTER_FULL_NAME and CLUSTER_AWS_REGION

## Setup Autoscaling
[Try this](https://kumorilabs.com/blog/k8s-5-setup-horizontal-pod-cluster-autoscaling-kubernetes)

```
kops edit ig nodes
```
change values for maxSize
Make sure it matches kubernetes/autoscaler/set-autoscaler.sh


# Update the Cluster Autoscaler manifest
```
sh ./kubernetes/autoscaler/set-autoscaler.sh
```

Once deployed view the autoscaler logs:
```
kubectl logs deployment/cluster-autoscaler --namespace=kube-system
```

If there is an error, it is likely a permission issue for default user in kube-system namespace
first run:
```
kubectl create clusterrolebinding --user system:serviceaccount:kube-system:default kube-system-cluster-admin --clusterrole cluster-admin
```

Add Additional policy (additionalPolicies below)
kops edit cluster --name ${CLUSTER_FULL_NAME}

spec:
.
.
  topology:
    dns:
      type: Public
    masters: public
    nodes: public
  additionalPolicies:
    node: |
      [
        {
          "Effect": "Allow",
          "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
          ],
          "Resource": ["*"]
        }
      ]


kops update cluster ${CLUSTER_FULL_NAME} --yes

aws iam create-policy --policy-document file://kubernetes/autoscaler/policy-cluster-autoscaler.json --policy-name ClusterAutoScaling
aws iam attach-role-policy --role-name ${CLUSTER_FULL_NAME} --policy-arn arn:aws:iam::`aws sts get-caller-identity --output text --query 'Account'`:policy/ClusterAutoScaling
kubectl apply -f ./kubernetes/autoscaler/cluster-autoscaler-deploy.yaml
kubectl logs deployment/cluster-autoscaler --namespace=kube-system

# Install / configure persistent volume
```
edit kubernetes/manifest.yaml
set the fs id
set the region
kubectl apply -f manifest.yaml
```

# Set up Monitoring metrics:
```
./kubernetes/monitoring/prometheus.sh
```
