#!/bin/sh

# Install kops
is_kops=$(which kops |grep kops)
if [ -z ${is_kops} ]; then
  curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
  chmod +x kops-linux-amd64
  sudo mv kops-linux-amd64 /usr/local/bin/kops
fi

# Install kubectl
is_kubectl=$(which kubectl |grep kubectl)
if [ -z ${is_kubectl} ]; then
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/amd64/kubectl
  sudo chmod +x kubectl
  sudo mv kubectl /usr/local/bin/kubectl
fi
