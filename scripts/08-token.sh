#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

export VAULT_ADDR="http://localhost:8200"
export VAULT_TOKEN="$(kubectl get secrets/vault-tokens -n $(namespace) -o jsonpath={.data.admin} | base64 --decode)"

POD_NAME=$(kubectl get pods -l app=exampleapp-simple -o jsonpath='{.items[*].metadata.name}')
JWT_TOKEN=$(kubectl exec ${POD_NAME} -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)

TOKEN=$(vault write -field token auth/kubernetes/login role=exampleapp-role jwt="${JWT_TOKEN}")

echo "export VAULT_TOKEN=${TOKEN}" > local.env
echo "export VAULT_ADDR=http://localhost:8200" >> local.env