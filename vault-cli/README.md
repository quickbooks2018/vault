# Vault CLI

### Userpass Auth

```bash
kubectl -n vault exec -it vault-0 -- sh
vault status
vault login
vault auth enable userpass
```