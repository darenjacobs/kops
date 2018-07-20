#!/bin/sh

# Full DNS name for of the cluster
export CLUSTER_NAME="fhlbny.cluster.k8s.local"

# Run k8s in existing VPC
export VPC_ID="vpc-eec7e28a"
export NETWORK_CIDR=172.31.0.0/16
export SUBNET_IDS="subnet-ff9448d5,subnet-3462c46c,subnet-179a1561"
export SUBNET_CIDR="172.31.48.0/20,172.31.16.0/20,172.31.0.0/20"


# Get Availability Zones
export CLUSTER_AWS_ZONES="us-east-1b,us-east-1d,us-east-1c"
#export CLUSTER_AWS_ZONES="$(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output text | awk -v OFS="," '$1=$1')"

# Create state store bucket
export S3_BUCKET="${CLUSTER_NAME}-state"
export KOPS_STATE_STORE="s3://${S3_BUCKET}"
aws s3 mb $KOPS_STATE_STORE
aws s3api put-bucket-versioning --bucket ${S3_BUCKET} --versioning-configuration Status=Enabled


# Create the cluster
kops create cluster \
  --name ${CLUSTER_NAME} \
  --vpc ${VPC_ID} \
  --subnets ${SUBNET_IDS} \
  --zones ${CLUSTER_AWS_ZONES} \
  --master-count 3 \
  --master-size m4.large \
  --master-zones ${CLUSTER_AWS_ZONES} \
  --node-count 3 \
  --node-size m4.large \
  --ssh-public-key "~/.ssh/id_rsa.pub" \
  --networking weave \
  --state ${KOPS_STATE_STORE} --yes
