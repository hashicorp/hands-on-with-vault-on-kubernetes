#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

DIR="$(pwd)/tls"

rm -rf "${DIR}"
mkdir -p "${DIR}"

# Create the conf file
cat > "${DIR}/openssl.cnf" << EOF
[req]
default_bits = 2048
encrypt_key  = no
default_md   = sha256
prompt       = no
utf8         = yes

distinguished_name = req_distinguished_name
req_extensions     = v3_req

[req_distinguished_name]
C  = US
ST = Oregon
L  = Portland
O  = OSCON19
CN = vault

[v3_req]
basicConstraints     = CA:FALSE
subjectKeyIdentifier = hash
keyUsage             = digitalSignature, keyEncipherment
extendedKeyUsage     = clientAuth, serverAuth
subjectAltName       = @alt_names

[alt_names]
DNS.1 = *.$(vault-release)-ha-server.$(namespace).svc.cluster.local
DNS.2 = $(vault-release).$(namespace).svc.cluster.local
EOF

# Generate Vault's certificates and a CSR
openssl genrsa -out "${DIR}/vault.key" 2048

openssl req \
  -new -key "${DIR}/vault.key" \
  -out "${DIR}/vault.csr" \
  -config "${DIR}/openssl.cnf"

# Create our CA
openssl req \
  -new \
  -newkey rsa:2048 \
  -days 120 \
  -nodes \
  -x509 \
  -subj "/C=US/ST=California/L=The Cloud/O=Vault CA" \
  -keyout "${DIR}/ca.key" \
  -out "${DIR}/ca.crt"

# Sign CSR with our CA
openssl x509 \
  -req \
  -days 120 \
  -in "${DIR}/vault.csr" \
  -CA "${DIR}/ca.crt" \
  -CAkey "${DIR}/ca.key" \
  -CAcreateserial \
  -extensions v3_req \
  -extfile "${DIR}/openssl.cnf" \
  -out "${DIR}/vault.crt"

# Export combined certs for vault
cat "${DIR}/vault.crt" "${DIR}/ca.crt" > "${DIR}/vault-combined.crt"

kubectl delete secret vault-tls -n $(namespace) --ignore-not-found
kubectl delete secret vault-tls -n default --ignore-not-found

kubectl create secret generic vault-tls -n $(namespace) \
  --from-file="${DIR}/ca.crt" \
  --from-file="vault.crt=${DIR}/vault-combined.crt" \
  --from-file="vault.key=${DIR}/vault.key"

kubectl create secret generic vault-tls -n default \
  --from-file="${DIR}/ca.crt" \
  --from-file="vault.crt=${DIR}/vault-combined.crt" \
  --from-file="vault.key=${DIR}/vault.key"