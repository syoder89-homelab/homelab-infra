# -----------------------------------------------------------------------------
# Artifact Registry: Docker image repositories + keyless push via GitHub OIDC
#
# Applied locally (like bootstrap/). The gke-deployer SA does not have
# artifactregistry.admin or iam.serviceAccountAdmin, so this cannot be
# managed by GitHub Actions without first expanding its scope.
#
# Pre-requisites:
#   - bootstrap/ module already applied (github-actions-pool + github-oidc
#     provider exist, with attribute.ref mapped)
#   - Run: terraform init -backend-config="bucket=${PROJECT_ID}-terraform-state"
# -----------------------------------------------------------------------------

# --- Look up the existing WIF pool and provider from bootstrap/ ---

data "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-actions-pool"
}

data "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = "github-actions-pool"
  workload_identity_pool_provider_id = "github-oidc"
}

# --- Artifact Registry repositories (one per service) ---

resource "google_artifact_registry_repository" "tank_monitor" {
  repository_id = "tank-monitor"
  location      = var.location
  format        = "DOCKER"
  description   = "Docker images for tank-monitor"
}

resource "google_artifact_registry_repository" "tasmota_monitor" {
  repository_id = "tasmota-monitor"
  location      = var.location
  format        = "DOCKER"
  description   = "Docker images for tasmota-monitor"
}

# --- Dedicated builder service accounts (one per service) ---

resource "google_service_account" "tank_monitor_builder" {
  account_id   = "tank-monitor-builder"
  display_name = "tank-monitor Image Builder"
  description  = "Keyless image builds for tank-monitor via GitHub Actions OIDC"
}

resource "google_service_account" "tasmota_monitor_builder" {
  account_id   = "tasmota-monitor-builder"
  display_name = "tasmota-monitor Image Builder"
  description  = "Keyless image builds for tasmota-monitor via GitHub Actions OIDC"
}

# --- Grant each SA write access to its own repository ONLY ---

resource "google_artifact_registry_repository_iam_member" "tank_monitor_writer" {
  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.tank_monitor.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.tank_monitor_builder.email}"
}

resource "google_artifact_registry_repository_iam_member" "tasmota_monitor_writer" {
  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.tasmota_monitor.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.tasmota_monitor_builder.email}"
}

# --- Allow GitHub Actions to impersonate each SA ---
#
# The principalSet scopes to the specific repo, so only tokens from
# syoder89-homelab/{repo} can impersonate each SA.
#
# Branch enforcement (refs/heads/main only) is applied at the WIF
# attribute_condition layer in bootstrap/ — IAM conditions on SA bindings
# do not support the attribute.* namespace from WIF token exchange.

resource "google_service_account_iam_member" "tank_monitor_wif" {
  service_account_id = google_service_account.tank_monitor_builder.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${data.google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_org}/tank-monitor"
}

resource "google_service_account_iam_member" "tasmota_monitor_wif" {
  service_account_id = google_service_account.tasmota_monitor_builder.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${data.google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_org}/tasmota-monitor"
}
