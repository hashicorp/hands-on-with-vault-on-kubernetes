#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

helm upgrade --install $(consul-release) helm/vault-backend --namespace $(namespace)
kubectl rollout status statefulset/$(consul-release)-consul-server  --namespace $(namespace)
helm test $(consul-release)

kubectl wait --for=condition=complete job/vault-backend-vault-acl -n $(namespace)

PODNAME=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" -n $(namespace) -l app=vault-backend --field-selector=status.phase=Succeeded)
TOKEN=$(kubectl logs ${PODNAME} -n $(namespace) | sed -n -e 's/^SecretID:[[:space:]]*\(.*\)/\1/p')

kubectl delete secret -n $(namespace) vault-backend-token --ignore-not-found
kubectl create secret -n $(namespace) generic vault-backend-token --from-literal=token=${TOKEN}