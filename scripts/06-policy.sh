#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

export VAULT_ADDR="http://localhost:8200"
export VAULT_TOKEN="$(kubectl get secrets/vault-tokens -n $(namespace) -o jsonpath={.data.admin} | base64 --decode)"

vault policy write exampleapp-kv - <<EOH
path "secret/data/exampleapp/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOH

vault write auth/kubernetes/role/exampleapp-role \
  bound_service_account_names="default" \
  bound_service_account_namespaces="default" \
  policies="default,exampleapp-kv" \
  ttl="15m"

vault kv put secret/data/exampleapp/config \
  ttl="30s" \
  username="exampleapp" \
  password="osc0nisinportland"