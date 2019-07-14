#!/bin/bash -
set -Eeuo pipefail

source "$(pwd)/scripts/__helpers.sh"

echo "--> Unpacking and installing"
docker run -v $HOME/bin:/software sethvargo/hashicorp-installer vault 1.1.2
sudo chown $(whoami):$(whoami) $HOME/bin/vault
sudo chmod +x $HOME/bin/vault

echo "--> Setting PATH"
export PATH="${PATH}:${HOME}/bin"

echo "--> Installing completions"
vault -autocomplete-install || true

echo "--> Done!"
exec $SHELL