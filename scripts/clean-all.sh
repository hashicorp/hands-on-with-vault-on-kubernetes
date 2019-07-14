#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

gcloud container clusters delete "$(cluster-name)" --async --quiet --project="$(google-project)" --region="$(google-region)"

rm -rf tls/

pgrep kubectl | while read -r pid ; do
    kill ${pid}
done