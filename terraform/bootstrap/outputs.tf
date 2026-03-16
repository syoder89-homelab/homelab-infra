output "workload_identity_provider" {
  description = "Workload Identity Provider — set as GCP_WORKLOAD_IDENTITY_PROVIDER GitHub variable"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "gke_deployer_service_account" {
  description = "GKE deployer service account email — set as GCP_SERVICE_ACCOUNT GitHub variable"
  value       = google_service_account.gke_deployer.email
}

output "argocd_service_account_email" {
  description = "ArgoCD service account email for GKE access"
  value       = google_service_account.argocd.email
}

output "argocd_wif_provider" {
  description = "Full resource name of the K8s WIF provider (used in ArgoCD credential config)"
  value       = google_iam_workload_identity_pool_provider.k8s.name
}

output "argocd_credential_config" {
  description = "GCP credential configuration JSON for ArgoCD. Save as a file and set GOOGLE_APPLICATION_CREDENTIALS to point to it."
  value = jsonencode({
    type                              = "external_account"
    audience                          = "//iam.googleapis.com/${google_iam_workload_identity_pool_provider.k8s.name}"
    subject_token_type                = "urn:ietf:params:oauth:token-type:jwt"
    token_url                         = "https://sts.googleapis.com/v1/token"
    service_account_impersonation_url = "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.argocd.email}:generateAccessToken"
    credential_source = {
      file = "/var/run/secrets/tokens/gcp-token"
      format = {
        type = "text"
      }
    }
  })
}
