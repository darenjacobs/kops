#!/bin/sh
export MIN_NODES="3"
export MAX_NODES="9"
export CLUSTER_FULL_NAME="fhlbny.cluster.k8s.local"
export CLUSTER_AWS_REGION="us-east-1"

# Create AWS IAM policy to allow the cluster to make changes to AWS Autoscaling group
aws iam put-role-policy --role-name nodes.${CLUSTER_FULL_NAME} \
    --policy-name asg-nodes.${CLUSTER_FULL_NAME} \
    --policy-document file://policy-cluster-autoscaler.json

# Update Cluster Autoscaler manifest
sed -i -e "s|--nodes=.*|--nodes=${MIN_NODES}:${MAX_NODES}:nodes.${CLUSTER_FULL_NAME}|g" \
    ./cluster-autoscaler-deploy.yaml
sed -i -e "s|value: .*|value: ${CLUSTER_AWS_REGION}|g" \
    ./cluster-autoscaler-deploy.yaml

kubectl apply -f ./cluster-autoscaler-deploy.yaml
