# Vault CLI

### Vault Policies
```bash
kubectl -n vault exec -it vault-0 -- sh
vault status
vault login
vault auth list 
vault auth list --detailed
```

- dev_secret_policy
- Note: "kv is a path best is to set this as dev"
```bash
path "kv/apps/env/dev/*" {
  capabilities = ["create", "read", "update", "list"]
}

path "kv/*" {
  capabilities = ["list","read"]
}
```

- prod_secret_policy
```bash
path "prod/apps/env/*" {
  capabilities = ["create", "read", "update", "list"]
}

path "prod/*" {
  capabilities = ["list","read"]
}
```

### Userpass Auth

```bash
kubectl -n vault exec -it vault-0 -- sh
vault status
vault login
vault auth list 
vault auth list --detailed
vault auth enable userpass

vault write --help
vault write -h
vault write auth/userpass/users/qasim password=qasim policies=dev
vault write auth/userpass/users/taha password=taha policies=dev
```

- Vault CLI Login with userpass
```bash
vault login -method=userpass username=qasim
```