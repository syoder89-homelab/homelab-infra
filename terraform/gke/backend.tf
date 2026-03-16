terraform {
  backend "gcs" {
    # Bucket must be created manually before first terraform init:
    #   gsutil mb -l us-central1 gs://${PROJECT_ID}-terraform-state
    #   gsutil versioning set on gs://${PROJECT_ID}-terraform-state
    # Then set the bucket name via:
    #   terraform init -backend-config="bucket=${PROJECT_ID}-terraform-state"
    prefix = "gke-staging"
  }
}
