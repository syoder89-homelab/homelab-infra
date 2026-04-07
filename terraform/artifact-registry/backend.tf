terraform {
  backend "gcs" {
    # terraform init -backend-config="bucket=${PROJECT_ID}-terraform-state"
    prefix = "artifact-registry"
  }
}
