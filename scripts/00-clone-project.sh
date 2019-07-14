#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

git clone https://github.com/hashicorp/hands-on-with-vault-on-kubernetes.git
