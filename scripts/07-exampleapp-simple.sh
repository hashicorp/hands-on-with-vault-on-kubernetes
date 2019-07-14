#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

kubectl apply -f kubernetes/exampleapp-simple.yaml

kubectl rollout status deployment/exampleapp-simple

POD_NAME=$(kubectl get pods -l app=exampleapp-simple -o jsonpath='{.items[*].metadata.name}')

kubectl port-forward $POD_NAME 8080:8080 &