#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

VAULT_ACL_RELEASE=$(vault-release)-acl

helm upgrade --install ${VAULT_ACL_RELEASE} helm/vault-helm-acl --namespace $(namespace)
kubectl wait --for=condition=complete job/${VAULT_ACL_RELEASE}-acl-init -n $(namespace)

PODNAME=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" -n $(namespace) -l app=${VAULT_ACL_RELEASE}-acl-init --field-selector=status.phase=Succeeded)
TOKEN=$(kubectl logs ${PODNAME} -n $(namespace) | sed -n -e 's/^token[[:space:]][[:space:]]*\(.*\)/\1/p' | base64)

kubectl get secrets -o yaml vault-tokens -n $(namespace) | sed -e $'s/.*root:.*/  admin: '"${TOKEN}"$'\\\n&/' | kubectl apply -f -

helm test ${VAULT_ACL_RELEASE}