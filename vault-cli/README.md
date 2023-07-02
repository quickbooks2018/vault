# Vault CLI

### Vault Policies
```bash
kubectl -n vault exec -it vault-0 -- sh
vault status
vault login
vault auth list 
vault auth list --detailed
```

- Vault policy
```bash
vault policy --help
```
- dev_secret_policy
- Note: "In kv "metadata" "data" "delete" are options which must be added"
- Note: "You can also provide access to option name undelete just like undo, so they can undo any delete operation"
```bash
path "kv/metadata/*" {
  capabilities = ["list"]
}

path "kv/metadata/apps/env/dev/*" {
  capabilities = ["list", "read"]
}

path "kv/data/apps/env/dev/*" {
  capabilities = ["list", "read", "update"]
}
```

- prod_secret_policy
```bash
path "kv/metadata/*" {
  capabilities = ["list"]
}

path "prod/metadata/apps/env/*" {
  capabilities = ["list", "read"]
}
  
path "prod/data/apps/env/*" {
  capabilities = ["list", "read", "update"]
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