output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.staging.name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.staging.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate (base64-encoded)"
  value       = google_container_cluster.staging.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "kubeconfig_command" {
  description = "gcloud command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.staging.name} --zone ${var.zone} --project ${var.project_id}"
}
