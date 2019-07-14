#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

export VAULT_ADDR="http://localhost:8200"
export VAULT_TOKEN="$(kubectl get secrets/vault-tokens -n $(namespace) -o jsonpath={.data.admin} | base64 --decode)"
INSTANCE_IP=$(kubectl get service mysql --no-headers -o custom-columns=":spec.clusterIP")

echo "${INSTANCE_IP}"

# Enable the database secrets engine
vault secrets enable database

# Configure the database secrets engine TTLs
vault write database/config/exampleapp-db \
  plugin_name="mysql-database-plugin" \
  connection_url="{{username}}:{{password}}@tcp(${INSTANCE_IP}:3306)/" \
  allowed_roles="readonly" \
  username="root" \
  password="osc0n2019"

# Create a role which will create a readonly user
vault write database/roles/readonly \
  db_name="mysql" \
  creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT SELECT ON *.* TO '{{name}}'@'%';" \
  default_ttl="1h" \
  max_ttl="24h"

# Create a new policy which allows generating these dynamic credentials
vault policy write exampleapp-db -<<EOF
path "database/creds/readonly" {
  capabilities = ["read"]
}
EOF

# Update the Vault kubernetes auth mapping to include this new policy
vault write auth/kubernetes/role/exampleapp-role \
  bound_service_account_names="default" \
  bound_service_account_namespaces="default" \
  policies="default,exampleapp-kv,exampleapp-db" \
  ttl="15m"