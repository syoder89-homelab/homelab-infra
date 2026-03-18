#!/bin/sh

# Bootstrap 1Password Connect Operator
#
# Usage: ./setup.sh <cluster-name>
#   cluster-name: Name of the cluster (e.g. Scorpius, GKE-Staging)
#
# WARNING: Ensure your kubectl context is set to the correct cluster
#          before running this script, or you will overwrite secrets
#          on the wrong cluster!
#
#   kubectl config current-context   # verify before running
#
# Requires matching 1Password vault items:
#   - "<cluster-name> Credentials File"   (document)
#   - "<cluster-name> Access Token: <cluster-name>" (item with 'credential' field)

set -eu

CLUSTER_NAME="${1:?Usage: $0 <cluster-name>}"
APP_DIR="$(cd "$(dirname "$0")" && pwd)/../../applications/onepassword-connect"

helm dependency update "${APP_DIR}"

# Chart 2.3.0+ mounts credentials as a file — store raw JSON, not base64-encoded
op_json="$(op document get --vault homelab "${CLUSTER_NAME} Credentials File" --format json)"
op_token="$(op item get --vault homelab "${CLUSTER_NAME} Access Token: ${CLUSTER_NAME}" --fields credential --reveal)"

kubectl create namespace onepassword-connect --dry-run=client -o yaml | kubectl apply -f -
kubectl -n onepassword-connect create secret generic op-credentials \
  --from-literal=1password-credentials.json="$op_json" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl -n onepassword-connect create secret generic onepassword-token \
  --from-literal=token="$op_token" \
  --dry-run=client -o yaml | kubectl apply -f -

helm template -n onepassword-connect onepassword-connect "${APP_DIR}" \
  --values "${APP_DIR}/values.yaml" --include-crds \
  | kubectl apply -f -
