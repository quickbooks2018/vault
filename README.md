# Hashicorp Vault

- Vault Helm Chart

- https://github.com/hashicorp/vault-helm

- Vault by default is not enabled.
- 
```bash
helm repo ls
helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp
helm search repo hashicorp/vault --versions
helm show values hashicorp/vault --version 0.25.0
helm show values hashicorp/vault --version 0.25.0 > vault-values.yaml
helm repo update
helm upgrade --install vault hashicorp/vault --set='ui.enabled=true' --namespace vault --create-namespace --version 0.25.0 -f vault-values.yaml --wait
```

