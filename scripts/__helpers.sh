# google-project returns the name of the current project, accounting for a
# variety of common environments. If no project is found in any of the common
# places, an error is returned.
google-project() {
  (
    set -Eeuo pipefail

    local project="${PROJECT:-${GOOGLE_PROJECT:-${GOOGLE_CLOUD_PROJECT:-${DEVSHELL_PROJECT_ID:-}}}}"
    if [ -z "${project:-}" ]; then
      echo "Missing project ID. Please set PROJECT, GOOGLE_PROJECT, or"
      echo "GOOGLE_CLOUD_PROJECT to the ID of your project to continue:"
      echo ""
      echo "    export GOOGLE_CLOUD_PROJECT=$(whoami)-foobar123"
      echo ""
      return 127
    fi
    echo "${project}"
  )
}

# gke-cluster-name is the name of the cluster for the given suffix.
gke-cluster-name() {
  (
    set -Eeuo pipefail

    echo "gke_$(google-project)_$(google-region)_${1}"
  )
}

# gke-latest-master-version returns the latest GKE master version.
gke-latest-master-version() {
  (
    set -Eeuo pipefail

    gcloud container get-server-config \
      --project="$(google-project)" \
      --region="$(google-region)" \
      --format='value(validMasterVersions[0])' \
      2>/dev/null
  )
}

# google-region returns the region in which resources should be created. This
# variable must be changed before running any commands.
google-region() {
  (
    echo "us-west1"
  )
}

vault-service-account() {
  (
    echo "vault-server"
  )
}

vault-service-account-email() {
  (
    echo "$(vault-service-account)@$(google-project).iam.gserviceaccount.com"
  )
}

keyring() {
  (
    echo "vault"
  )
}

key() {
  (
    echo "init"
  )
}

cluster-name() {
  (
    echo "vault-on-kubernetes"
  )
}

namespace() {
  (
    echo "prod"
  )
}

consul-release() {
  (
    echo "consul"
  )
}

vault-release() {
  (
    echo "vault"
  )
}