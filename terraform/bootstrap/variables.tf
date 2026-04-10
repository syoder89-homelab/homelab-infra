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

variable "unrestricted_repos" {
  description = "GitHub repos allowed to exchange OIDC tokens on any ref (e.g. GKE management workflows)"
  type        = list(string)
  default     = ["homelab-infra", "homelab-apps"]
}

variable "main_only_repos" {
  description = "GitHub repos allowed to exchange OIDC tokens on refs/heads/main only (e.g. image builders)"
  type        = list(string)
  default     = ["tank-monitor", "tasmota-monitor", "stock-ticker"]
}

variable "gke_deployer_repos" {
  description = "GitHub repos allowed to impersonate the gke-deployer SA (subset of unrestricted_repos)"
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
