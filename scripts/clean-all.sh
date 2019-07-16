#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

kubectl delete -f kubernetes/exampleapp-database-sidecar.yaml --ignore-not-found
kubectl delete -f kubernetes/mysql.yaml --ignore-not-found
kubectl delete -f kubernetes/exampleapp-sidecar.yaml --ignore-not-found
kubectl delete -f kubernetes/exampleapp-simple.yaml --ignore-not-found

gcloud container clusters delete "$(cluster-name)" --async --quiet --project="$(google-project)" --region="$(google-region)"

rm -rf tls/
rm -f vault-config.yaml

pgrep kubectl | while read -r pid ; do
    kill ${pid}
done