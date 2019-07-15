#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

kubectl apply -f kubernetes/mysql.yaml

kubectl rollout status deployment/mysql

PODNAME=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" -l app=mysql)

external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get svc mysql --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready-" && echo $external_ip