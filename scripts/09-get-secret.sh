#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

source local.env

vault kv get secret/data/exampleapp/config