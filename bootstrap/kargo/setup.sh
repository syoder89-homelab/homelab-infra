#!/bin/sh

# Bootstrap Kargo resources for homelab-infra
#
# Applies the Kargo Project, PromotionTasks, Warehouse, Stage,
# and GitHub PAT secret for the homelab-infra Kargo project.
# Kargo itself is deployed by the homelab-management repo.

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
kubectl create namespace homelab-infra --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "${SCRIPT_DIR}/manifests/"
