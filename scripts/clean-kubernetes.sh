#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

pgrep kubectl | while read -r pid ; do
  kill ${pid}
done

kubectl delete -f kubernetes/mysql.yaml --ignore-not-found
kubectl delete -f kubernetes/exampleapp-sidecar.yaml --ignore-not-found
kubectl delete -f kubernetes/exampleapp-simple.yaml --ignore-not-found

kubectl delete configmap $(vault-release)-service-config --ignore-not-found
kubectl delete serviceaccount vault-auth --ignore-not-found

helm del --purge vault-acl || true
helm del --purge vault || true
helm del --purge consul || true
kubectl delete ns $(namespace)