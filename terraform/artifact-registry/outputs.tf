output "wif_provider" {
  description = "Full WIF provider resource name — set as GCP_WORKLOAD_IDENTITY_PROVIDER in each GitHub repo's Actions variables"
  value       = data.google_iam_workload_identity_pool_provider.github.name
}

output "tank_monitor_service_account" {
  description = "tank-monitor builder SA email — set as GCP_SERVICE_ACCOUNT in the tank-monitor repo's Actions variables"
  value       = google_service_account.tank_monitor_builder.email
}

output "tasmota_monitor_service_account" {
  description = "tasmota-monitor builder SA email — set as GCP_SERVICE_ACCOUNT in the tasmota-monitor repo's Actions variables"
  value       = google_service_account.tasmota_monitor_builder.email
}

output "tank_monitor_image_base" {
  description = "Base image path for tank-monitor (append :<tag>)"
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/tank-monitor/tank-monitor"
}

output "tasmota_monitor_image_base" {
  description = "Base image path for tasmota-monitor (append :<tag>)"
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/tasmota-monitor/tasmota-monitor"
}
