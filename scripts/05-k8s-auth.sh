#!/bin/bash -

source "$(pwd)/scripts/__helpers.sh"

VAULT_PODNAME=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" -n $(namespace) -l app=vault --field-selector=status.phase=Running | head -n1)
kubectl port-forward ${VAULT_PODNAME} -n $(namespace) 8200:8200 &

kubectl get configmap $(vault-release)-service-config -n $(namespace) -o yaml | sed 's/namespace: '"$(namespace)"'/namespace: default/' | kubectl apply -f - --namespace=default || true

# kubernetes service account for vault authentication.
kubectl create serviceaccount vault-auth || true

# cluster role binding for vault authentication.
kubectl apply -f - <<EOH
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: vault-auth
  namespace: default
EOH

CLUSTER_FQN=$(gke-cluster-name "$(cluster-name)")

SECRET_NAME="$(kubectl get serviceaccount vault-auth \
  -o go-template='{{ (index .secrets 0).name }}')"

TR_ACCOUNT_TOKEN="$(kubectl get secret ${SECRET_NAME} \
  -o go-template='{{ .data.token }}' | base64 --decode)"

K8S_HOST="$(kubectl config view --raw \
  -o go-template="{{ range .clusters }}{{ if eq .name \"${CLUSTER_FQN}\" }}{{ index .cluster \"server\" }}{{ end }}{{ end }}")"

K8S_CACERT="$(gcloud container clusters describe $(cluster-name) --region $(google-region) --format="value(masterAuth.clusterCaCertificate)" | base64 --decode)"

export VAULT_ADDR="http://localhost:8200"
export VAULT_TOKEN="$(kubectl get secrets/vault-tokens -n $(namespace) -o jsonpath={.data.admin} | base64 --decode)"

# Enable the Kubernetes authentication method
vault auth enable kubernetes

# Configure Vault to talk to our Kubernetes host with the cluster's CA and the
# correct token reviewer JWT token
vault write auth/kubernetes/config \
  kubernetes_host="${K8S_HOST}" \
  kubernetes_ca_cert="${K8S_CACERT}" \
  token_reviewer_jwt="${TR_ACCOUNT_TOKEN}"
