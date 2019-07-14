#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

gcloud services enable \
  --async \
  --project="$(google-project)" \
  cloudapis.googleapis.com \
  cloudkms.googleapis.com \
  cloudresourcemanager.googleapis.com \
  cloudshell.googleapis.com \
  container.googleapis.com \
  containerregistry.googleapis.com \
  iam.googleapis.com

gcloud kms keyrings create $(keyring) \
  --project="$(google-project)" \
  --location="$(google-region)" || true

gcloud kms keys create $(key) \
  --project="$(google-project)" \
  --location="$(google-region)" \
  --keyring="$(keyring)" \
  --purpose="encryption" || true

gcloud iam service-accounts create $(vault-service-account) \
  --project="$(google-project)" \
  --display-name="vault server" || true

gcloud kms keys add-iam-policy-binding $(key) \
  --project="$(google-project)" \
  --location="$(google-region)" \
  --keyring="$(keyring)" \
  --member="serviceAccount:$(vault-service-account-email)" \
  --role="roles/cloudkms.cryptoKeyEncrypterDecrypter"

gcloud container clusters create $(cluster-name) \
  --project="$(google-project)" \
  --preemptible \
  --issue-client-certificate \
  --cluster-version="$(gke-latest-master-version)" \
  --enable-autorepair \
  --enable-autoupgrade \
  --enable-ip-alias \
  --machine-type="n1-standard-2" \
  --node-version="$(gke-latest-master-version)" \
  --num-nodes="1" \
  --region="$(google-region)" \
  --scopes="cloud-platform,compute-rw,storage-ro" \
  --service-account="$(vault-service-account-email)" \

gcloud container clusters get-credentials $(cluster-name) --region "$(google-region)"

kubectl cluster-info

helm init

kubectl rollout status deployment/tiller-deploy -n kube-system

kubectl apply -f kubernetes/tiller-rbac.yaml