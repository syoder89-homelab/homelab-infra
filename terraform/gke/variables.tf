variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for the cluster"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone for the zonal cluster (free tier requires zonal)"
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "gke-staging"
}

variable "system_node_machine_type" {
  description = "Machine type for the system node pool (always-on)"
  type        = string
  default     = "e2-small"
}

variable "workload_node_machine_type" {
  description = "Machine type for the workload node pool (sized to idle on a single worker)"
  type        = string
  default     = "e2-standard-2"
}

variable "workload_node_max_count" {
  description = "Maximum number of nodes in the workload node pool"
  type        = number
  default     = 3
}
