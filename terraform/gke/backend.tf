terraform {
  backend "gcs" {
    # Bucket must be created manually before first terraform init:
    #   gcloud storage buckets create gs://${PROJECT_ID}-terraform-state --location=us-central1 --uniform-bucket-level-access
    #   gcloud storage buckets update gs://${PROJECT_ID}-terraform-state --public-access-prevention
    #   gcloud storage buckets update gs://${PROJECT_ID}-terraform-state --versioning
    # Then set the bucket name via:
    #   terraform init -backend-config="bucket=${PROJECT_ID}-terraform-state"
    prefix = "gke-staging"
  }
}
