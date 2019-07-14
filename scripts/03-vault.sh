#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

helm upgrade --install $(vault-release) helm/vault-helm --namespace $(namespace)

kubectl rollout status statefulset/$(vault-release)-ha-server --namespace $(namespace)

PODNAME=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" -n $(namespace) -l app=vault-init --field-selector=status.phase=Succeeded)
TOKEN=$(kubectl logs ${PODNAME} -n $(namespace) | sed -n -e 's/^Initial Root Token:[[:space:]]*\(.*\)/\1/p')

kubectl create secret -n $(namespace) generic vault-tokens --from-literal=root=${TOKEN} --save-config