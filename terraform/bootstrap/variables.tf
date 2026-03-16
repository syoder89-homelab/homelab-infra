variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "github_org" {
  description = "GitHub organization for Workload Identity Federation"
  type        = string
  default     = "syoder89-homelab"
}

variable "github_repos" {
  description = "GitHub repos allowed to authenticate via Workload Identity Federation"
  type        = list(string)
  default     = ["homelab-infra", "homelab-apps"]
}

# --- On-prem Kubernetes WIF (for ArgoCD → GKE auth) ---

variable "k8s_oidc_issuer_uri" {
  description = "OIDC issuer URI of the on-prem K8s cluster. Get with: kubectl get --raw /.well-known/openid-configuration | jq -r .issuer"
  type        = string
}

variable "k8s_oidc_jwks_json" {
  description = "JWKS JSON from the on-prem K8s cluster. Get with: kubectl get --raw /openid/v1/jwks"
  type        = string
}

variable "argocd_namespace" {
  description = "Kubernetes namespace where ArgoCD is deployed"
  type        = string
  default     = "argocd"
}

variable "argocd_service_account" {
  description = "ArgoCD application-controller Kubernetes service account name"
  type        = string
  default     = "argocd-application-controller"
}
