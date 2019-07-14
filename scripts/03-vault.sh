#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

cat > vault-config.yaml <<EOF
serverHA:
  config: |
    ui = true

    api_addr = "https://RELEASE_NAME.NAMESPACE.svc.cluster.local"
    cluster_addr = "https://POD_IP:8201"

    listener "tcp" {
      address     = "127.0.0.1:8200"
      tls_disable = "true"
    }

    listener "tcp" {
      address     = "POD_IP:8200"
      tls_cert_file = "/vault/userconfig/vault-tls/vault.crt"
      tls_key_file  = "/vault/userconfig/vault-tls/vault.key"
      tls_disable_client_certs = true
    }

    storage "consul" {
      path = "vault"
      address = "HOST_IP:8500"
      token = "CONSUL_ACL_TOKEN"
    }

    seal "gcpckms" {
      project     = "$(google-project)"
      region      = "$(google-region)"
      key_ring    = "$(keyring)"
      crypto_key  = "$(key)"
    }
EOF

helm upgrade --install $(vault-release) helm/vault-helm --namespace $(namespace) -f vault-config.yaml

kubectl rollout status statefulset/$(vault-release)-ha-server --namespace $(namespace)

PODNAME=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" -n $(namespace) -l app=vault-init --field-selector=status.phase=Succeeded)
TOKEN=$(kubectl logs ${PODNAME} -n $(namespace) | sed -n -e 's/^Initial Root Token:[[:space:]]*\(.*\)/\1/p')

kubectl create secret -n $(namespace) generic vault-tokens --from-literal=root=${TOKEN} --save-config