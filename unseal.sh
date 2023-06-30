#!/bin/bash

# First delete the pods
kubectl -n vault delete pods vault-0 vault-1 vault-2

root_token='hvs.UGfPf1bFDaP8jxYnlhL2lfeh'


sleep 6

# Define the unseal keys
UNSEAL_KEYS=(
"/OOTbeZP0SLco6bopWzBHYNdD/26JqxQ7XeFDdO0e3t6"
"+D93zI//7kKP9Yh4IDRyRQFkStFHvOygLv6nISCUgjwT"
"GPRBp+83M+EoikeHpvO5pbXRVf/M5yJcquspe91PSIl3"
"aKHyZbRcPe5LhURkzTzenuWc6MgwqheOnASg7oSNNCg5"
"CnZDgIaEXJ9qU7KeExofc9xQcbck9QlfYq+vZ6WR4YXC"
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