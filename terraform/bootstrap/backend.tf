terraform {
  backend "gcs" {
    # Same bucket as gke/, different prefix
    # terraform init -backend-config="bucket=${PROJECT_ID}-terraform-state"
    prefix = "bootstrap"
  }
}
