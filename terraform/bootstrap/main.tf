# -----------------------------------------------------------------------------
# Bootstrap: Workload Identity Federation + Service Accounts
# Run this ONCE locally with `gcloud` auth to bootstrap GitHub Actions access.
# After this, the gke/ Terraform can be managed via GitHub Actions.
# -----------------------------------------------------------------------------

# --- Workload Identity Federation for GitHub Actions ---

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions OIDC"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc"
  display_name                       = "GitHub OIDC Provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  attribute_condition = join(" || ", concat(
    [for repo in var.unrestricted_repos :
      "assertion.repository == \"${var.github_org}/${repo}\""
    ],
    [for repo in var.main_only_repos :
      "(assertion.repository == \"${var.github_org}/${repo}\" && assertion.ref == \"refs/heads/main\")"
    ]
  ))

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# --- Service Account for GitHub Actions (GKE management) ---

resource "google_service_account" "gke_deployer" {
  account_id   = "gke-deployer"
  display_name = "GKE Deployer (GitHub Actions)"
  description  = "Service account for GitHub Actions to manage GKE cluster"
}

resource "google_project_iam_member" "gke_deployer_container_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.gke_deployer.email}"
}

resource "google_project_iam_member" "gke_deployer_compute_network" {
  project = var.project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.gke_deployer.email}"
}

resource "google_project_iam_member" "gke_deployer_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.gke_deployer.email}"
}

# Grant storage access for Terraform state bucket
resource "google_project_iam_member" "gke_deployer_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.gke_deployer.email}"
}

# Allow only GKE-managing repos to impersonate the gke-deployer SA.
# tank-monitor and tasmota-monitor pass the attribute_condition above
# (can exchange tokens) but are NOT in this set — their builder SAs
# are bound separately in the artifact-registry/ module.
resource "google_service_account_iam_member" "github_actions_wif" {
  for_each = toset(var.gke_deployer_repos)

  service_account_id = google_service_account.gke_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_org}/${each.value}"
}

# --- Service Account for ArgoCD ---

resource "google_service_account" "argocd" {
  account_id   = "argocd-deployer"
  display_name = "ArgoCD Deployer"
  description  = "Service account for ArgoCD to deploy workloads to GKE"
}

resource "google_project_iam_member" "argocd_container_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.argocd.email}"
}

# --- Workload Identity Federation for on-prem ArgoCD ---
# Allows ArgoCD's K8s service account to impersonate the GCP service account
# using short-lived tokens (no long-lived keys).

resource "google_iam_workload_identity_pool" "k8s" {
  workload_identity_pool_id = "homelab-k8s-pool"
  display_name              = "Homelab Kubernetes Pool"
  description               = "Workload Identity Pool for on-prem Kubernetes clusters"
}

resource "google_iam_workload_identity_pool_provider" "k8s" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.k8s.workload_identity_pool_id
  workload_identity_pool_provider_id = "homelab-k8s-oidc"
  display_name                       = "Homelab K8s OIDC Provider"

  attribute_mapping = {
    "google.subject" = "assertion.sub"
  }

  # Only allow the ArgoCD service account
  attribute_condition = "assertion.sub == 'system:serviceaccount:${var.argocd_namespace}:${var.argocd_service_account}'"

  oidc {
    issuer_uri = var.k8s_oidc_issuer_uri
    # Inline JWKS so GCP doesn't need to reach the on-prem K8s API server
    jwks_json = var.k8s_oidc_jwks_json
  }
}

# Allow ArgoCD K8s SA to impersonate the GCP ArgoCD service account
resource "google_service_account_iam_member" "argocd_wif" {
  service_account_id = google_service_account.argocd.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.k8s.name}/subject/system:serviceaccount:${var.argocd_namespace}:${var.argocd_service_account}"
}
