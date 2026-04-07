variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "GCP region for Artifact Registry repositories"
  type        = string
  default     = "us-central1"
}

variable "github_org" {
  description = "GitHub organization owning the source repos"
  type        = string
  default     = "syoder89-homelab"
}
