#!/usr/bin/env bash
# Extract Kubernetes OIDC issuer URI and JWKS for GCP Workload Identity Federation.
#
# Usage:
#   ./terraform/bootstrap/get-k8s-oidc.sh
#
# Outputs the values needed for terraform/bootstrap/terraform.tfvars:
#   k8s_oidc_issuer_uri  — The OIDC issuer URL from the K8s API server
#   k8s_oidc_jwks_json   — The JWKS JSON for inline token verification
#
# Prerequisites:
#   - kubectl configured and pointing to the on-prem cluster
#   - jq installed
#
set -euo pipefail

echo "Fetching OIDC configuration from Kubernetes API server..."

ISSUER=$(kubectl get --raw /.well-known/openid-configuration | jq -r '.issuer')
JWKS=$(kubectl get --raw /openid/v1/jwks)

echo ""
echo "Add these to terraform/bootstrap/terraform.tfvars:"
echo ""
echo "k8s_oidc_issuer_uri = \"${ISSUER}\""
echo ""
echo "k8s_oidc_jwks_json = <<-EOT"
echo "${JWKS}"
echo "EOT"
