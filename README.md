# Hashicorp Vault

- Kind HA 3 Nodes Cluster
- https://github.com/quickbooks2018/kind-nginx-ingress/tree/master
```bash
#!/bin/bash
# Purpose: Kubernetes Cluster
# extraPortMappings allow the local host to make requests to the Ingress controller over ports 80/443
# node-labels only allow the ingress controller to run on a specific node(s) matching the label selector
# https://kind.sigs.k8s.io/docs/user/ingress/


######################################
# Docker & Docker Compose Installation
######################################
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm -f get-docker.sh


#######################
# Kubectl Installation
#######################
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
kubectl version --client

####################
# Helm Installation
####################
# https://helm.sh/docs/intro/install/

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
cp /usr/local/bin/helm /usr/bin/helm
rm -f get_helm.sh
helm version

###################
# Kind Installation
###################
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.19.0/kind-linux-amd64
# curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64

# Latest Version
# https://github.com/kubernetes-sigs/kind
# curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.9.0/kind-$(uname)-amd64"
# curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64
# curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-linux-amd64
chmod +x ./kind

mv ./kind /usr/local/bin

#############
# Kind Config
#############
#cat << EOF > kind-config.yaml
#kind: Cluster
#apiVersion: kind.x-k8s.io/v1alpha4
#networking:
#  apiServerAddress: 0.0.0.0
#  apiServerPort: 8443
#EOF
  
# kind create --name cloudgeeks cluster --config kind-config.yaml --image kindest/node:v1.21.10
  
  # ssh -N -L 8443:0.0.0.0:8443 cloud_user@d8d0041c.mylabserver.com
  
 # export KUBECONFIG=".kube/config"
  
 ####################  
 # Multi-Node Cluster
 ####################
 cat > kind-config.yaml <<EOF
# three node (two workers) cluster config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: 0.0.0.0
  apiServerPort: 8443
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
        eviction-hard: "memory.available<5%"
        system-reserved: "memory=1Gi"
        kube-reserved: "memory=1Gi"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        eviction-hard: "memory.available<5%"
        system-reserved: "memory=1Gi"
        kube-reserved: "memory=1Gi"
- role: worker
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        eviction-hard: "memory.available<5%"
        system-reserved: "memory=1Gi"
        kube-reserved: "memory=1Gi"
EOF
  
 kind create --name cloudgeeks cluster --config kind-config.yaml --image kindest/node:v1.25.11
 
 
  export KUBECONFIG=".kube/config"
 
  #End
```


- Vault Helm Chart

- https://github.com/hashicorp/vault-helm

- Vault by default is not enabled.

```bash
helm repo ls
helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp
helm search repo hashicorp/vault --versions
helm show values hashicorp/vault --version 0.25.0
helm show values hashicorp/vault --version 0.25.0 > vault-values.yaml
helm repo update
helm upgrade --install vault hashicorp/vault --set='ui.enabled=true' --set "server.ha.enabled=true" --namespace vault --create-namespace --version 0.25.0 -f vault-values.yaml --wait
```

