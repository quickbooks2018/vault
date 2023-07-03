### Enable k8s auth

Note: When pod run as a service account, it will have a token mounted at /var/run/secrets/kubernetes.io/serviceaccount/token. This token is used to authenticate with the Kubernetes API. The token is scoped to a specific namespace, so it can only access resources in that namespace.

```bash
kubectl -n vault exec -it vault-0 -- sh

vault login
vault auth enable kubernetes

vault write auth/kubernetes/config \
token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443 \
kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
issuer="https://kubernetes.default.svc.cluster.local"
```

- Application to Access Secrets in Vault, we need to setup the policy in vault, in order inject secrets in application pod
- Basic Secret Injection
- In order for us to start using secrets in vault, we need to setup a policy.

```bash
#Create a role for our app

kubectl -n vault exec -it vault-0 -- sh 

vault write auth/kubernetes/role/basic-secret-role \
   bound_service_account_names=basic-secret \
   bound_service_account_namespaces=example-app \
   policies=basic-secret-policy \
   ttl=1h
```

- The above maps our Kubernetes service account, used by our pod, to a policy. Now lets create the policy to map our service account to a bunch of secrets.

```bash
kubectl -n vault exec -it vault-0 -- sh 

cat <<EOF > /home/vault/app-policy.hcl
path "secret/data/basic-secret/*" {
  capabilities = ["read"]
}
EOF
vault policy write basic-secret-policy /home/vault/app-policy.hcl
```

- Vault Policy troubleshooting
```bash
vault kv get secret/data/basic-secret/helloworld
```

- Now our service account for our pod can access all secrets under secret/basic-secret/* Lets create some secrets.

```bash
kubectl -n vault exec -it vault-0 -- sh 
vault secrets enable -path=secret/ kv-v2
vault kv put secret/basic-secret/helloworld username=dbuser password=12345678
```

- Lets deploy our app and see if it works
```bash
kubectl apply -f ./app/deployment.yaml
kubectl -n example-app get pods
```