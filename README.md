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
- tls bash script
```bash
#!/bin/bash

#Define the domain name

DOMAIN='cloudgeeks.tk'
SUBDOMAIN='*'
DAYS='36500'
default_bits='2048'

#Organization Details
COUNTRY='PK'
PROVINCE='Punjab'
LOCATION='Lahore'
DEPARTMENT='IT'
COMMONNAME='Self Signed Certificate'


# Define where to store the generated certs and metadata.
DIR="$(pwd)/tls"

# Optional: Ensure the target directory exists and is empty.
rm -rf "${DIR}"
mkdir -p "${DIR}"





# Create the openssl configuration file. This is used for both generating
# the certificate as well as for specifying the extensions. It aims in favor
# of automation, so the DN is encoding and not prompted.
cat > "${DIR}/openssl.cnf" << EOF
[req]
default_bits = ${default_bits}
encrypt_key  = no # Change to encrypt the private key using des3 or similar
default_md   = sha256
prompt       = no
utf8         = yes
# Speify the DN here so we aren't prompted (along with prompt = no above).
distinguished_name = req_distinguished_name
# Extensions for SAN IP and SAN DNS
req_extensions = v3_req
# Be sure to update the subject to match your organization.
[req_distinguished_name]
C  = "$COUNTRY"
ST = "$PROVINCE"
L  = "$LOCATION"
O  = "$DEPARTMENT"
CN = "$COMMONNAME"
# Allow client and server auth. You may want to only allow server auth.
# Link to SAN names.
[v3_req]
basicConstraints     = CA:FALSE
subjectKeyIdentifier = hash
keyUsage             = digitalSignature, keyEncipherment
extendedKeyUsage     = clientAuth, serverAuth
subjectAltName       = @alt_names
# Alternative names are specified as IP.# and DNS.# for IP addresses and
# DNS accordingly. 
[alt_names]
IP.1  = 127.0.0.1
DNS.1 = "$DOMAIN"
DNS.2 = "$SUBDOMAIN"."$DOMAIN"
DNS.3 = "$SUBDOMAIN"."$SUBDOMAIN"."$DOMAIN"
EOF

# Create the certificate authority (CA). This will be a self-signed CA, and this
# command generates both the private key and the certificate. You may want to 
# adjust the number of bits (4096 is a bit more secure, but not supported in all
# places at the time of this publication). 
#
# To put a password on the key, remove the -nodes option.
#
# Be sure to update the subject to match your organization.
openssl req \
  -new \
  -newkey rsa:${default_bits} \
  -days ${DAYS} \
  -nodes \
  -x509 \
  -subj "/C="$COUNTRY"/ST="$PROVINCE"/L="$LOCATION"/O="$DEPARTMENT"" \
  -keyout "${DIR}/CA.key" \
  -out "${DIR}/CA.crt"
#
# For each server/service you want to secure with your CA, repeat the
# following steps:
#

# Generate the private key for the service. Again, you may want to increase
# the bits to 4096.
openssl genrsa -out "${DIR}/"$DOMAIN".key" ${default_bits}

# Generate a CSR using the configuration and the key just generated. We will
# give this CSR to our CA to sign.
openssl req \
  -new -key "${DIR}/"$DOMAIN".key" \
  -out "${DIR}/"$DOMAIN".csr" \
  -config "${DIR}/openssl.cnf"
  
# Sign the CSR with our CA. This will generate a new certificate that is signed
# by our CA.
openssl x509 \
  -req \
  -days ${DAYS} \
  -in "${DIR}/"$DOMAIN".csr" \
  -CA "${DIR}/CA.crt" \
  -CAkey "${DIR}/CA.key" \
  -CAcreateserial \
  -extensions v3_req \
  -extfile "${DIR}/openssl.cnf" \
  -out "${DIR}/"$DOMAIN".crt"

# (Optional) Verify the certificate.
openssl x509 -in "${DIR}/"$DOMAIN".crt" -noout -text

# Generate PFX For Windows 
# openssl pkcs12 -export -out "$DOMAIN".pfx -inkey "$DOMAIN".key -in "$DOMAIN".crt

# https://aws.amazon.com/blogs/security/how-to-prepare-for-aws-move-to-its-own-certificate-authority/

# End
```


- Cloudflare tls

```bash
#!/bin/bash
apt-get update && apt-get install -y curl &&
curl -L https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssl_1.6.4_linux_amd64 -o /usr/local/bin/cfssl && \
curl -L https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssljson_1.6.4_linux_amd64 -o /usr/local/bin/cfssljson && \
chmod +x /usr/local/bin/cfssl && \
chmod +x /usr/local/bin/cfssljson


mkdir tls
cd tls

# CA Certificate authority
cat << EOF > /mnt/tls/ca-config.json
{
  "signing": {
    "default": {
      "expiry": "175200h"
    },
    "profiles": {
      "default": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "175200h"
      }
    }
  }
}
EOF

# Certificate Signing Request
cat << EOF > /mnt/tls/ca-csr.json
{
  "hosts": [
    "cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "PK",
      "L": "Lahore",
      "O": "cloudgeeks",
      "OU": "IT",
      "ST": "Punjab"
    }
  ]
}
EOF


#generate ca in /mnt
cfssl gencert -initca ca-csr.json | cfssljson -bare /mnt/tls/ca

#generate certificate in /mnt
cfssl gencert \
  -ca=/mnt/tls/ca.pem \
  -ca-key=/mnt/tls/ca-key.pem \
  -config=ca-config.json \
  -hostname="vault,vault.vault.svc.cluster.local,vault.vault.svc,localhost,127.0.0.1,vault.cloudgeeks.local" \
  -profile=default \
  ca-csr.json | cfssljson -bare /mnt/tls/vault
```

- Consul Helm Chart

- https://github.com/hashicorp/consul-k8s

```bash
helm repo ls
helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp
helm search repo hashicorp/consul --versions
helm show values hashicorp/consul --version 1.2.0
helm show values hashicorp/consul --version 1.2.0 > consul-values.yaml
helm repo update
```
```bash
helm upgrade --install consul --namespace vault hashicorp/consul --version 1.2.0 \
--set='client.enabled=true' \
--set='server.replicas=1' \
--set='server.disruptionBudget.maxUnavailable=1' \
--set='server.bootstrapExpect=1' \
--set='server.storage=50Gi' \
-f consul-values.yaml --wait
```

- Consul Yaml Template
```bash
helm template consul --namespace vault hashicorp/consul --version 1.2.0 \
--set='client.enabled=true' \
--set='server.replicas=1' \
--set='server.disruptionBudget.maxUnavailable=1' \
--set='server.bootstrapExpect=1' \
--set='server.storage=50Gi' \
-f consul-values.yaml --wait > consul-yaml-template.yaml
```

### TLS End to End Encryption
- Create the TLS secret
```bash
kubectl -n vault create secret tls tls-ca \
 --cert /mnt/tls/ca.pem  \
 --key /mnt/tls/ca-key.pem

kubectl -n vault create secret tls tls-server \
  --cert /mnt/tls/vault.pem \
  --key /mnt/tls/vault-key.pem
```
- Vault Helm Chart

- https://github.com/hashicorp/vault-helm

- Note: For vault, we are using custom vault values file which is vault-values.yaml

```bash
helm repo ls
helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp
helm search repo hashicorp/vault --versions
helm show values hashicorp/vault --version 0.25.0
# helm show values hashicorp/vault --version 0.25.0 > vault-values.yaml
helm repo update
```
```bash
helm upgrade --install vault hashicorp/vault \
  --set='ui.enabled=true' \
  --set='server.ha.enabled=true' \
  --set='server.ha.replicas=3' \
  --namespace vault \
  --create-namespace \
  --version 0.25.0 \
  -f vault-values.yaml \
  --wait
```
- Vault yaml template
```bash
helm template vault hashicorp/vault \
  --set='ui.enabled=true' \
  --set='server.ha.enabled=true' \
  --set='server.ha.replicas=3' \
  --namespace vault \
  --create-namespace \
  --version 0.25.0 \
  -f vault-values.yaml \
  --wait > vault-yaml-template.yaml
```
- Vault Commands

```bash
kubectl -n vault get pods
kubectl -n vault exec -it vault-0 -- vault operator init
```