#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

kubectl apply -f kubernetes/exampleapp-simple.yaml

kubectl rollout status deployment/exampleapp-simple