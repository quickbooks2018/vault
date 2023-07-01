#!/bin/bash

# First delete the pods
kubectl -n vault delete pods vault-0 vault-1 vault-2

root_token='hvs.dH1DyIFoeLsbLOcUUDTf0m4A'


sleep 9

# Define the unseal keys
UNSEAL_KEYS=(
"KHCgv3D5cr2VnLzxhZOjp8uxtf4ISRfMizdozPIKIWS5"
"AeGn2Z6auwf5/5uJbTeHHsLqIoarzOlag8DcmwKou5oc"
"5h3CQ0egZiN3EyQSkR7e1mTA7dS1zQZ4mKSsnlHVQl0Q"
"kSO661ROhX81LW3uWhSUimK++4YpYeCHb8TM16edVbcm"
"NxU+J/Q7fHjnWcLrHC64gEZi8+lUV6jDG+E2esXg4fHY"
)

# Define the vault pods
VAULT_PODS=("vault-0" "vault-1" "vault-2")

# Define the namespace
NAMESPACE="vault"

for pod in "${VAULT_PODS[@]}"; do
    echo "Unsealing $pod"
    for key in "${UNSEAL_KEYS[@]:0:3}"; do
        kubectl -n $NAMESPACE exec -it $pod -- vault operator unseal $key
    done
done

# End