# -----------------------------------------------------------------------------
# GKE Staging Cluster
# Free-tier zonal cluster with scale-to-zero workload nodes
# -----------------------------------------------------------------------------

# --- Networking ---

resource "google_compute_network" "gke" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke" {
  name          = "${var.cluster_name}-subnet"
  ip_cidr_range = "10.0.0.0/20"
  region        = var.region
  network       = google_compute_network.gke.id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.4.0.0/14"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.8.0.0/20"
  }
}

# --- GKE Cluster ---

resource "google_container_cluster" "staging" {
  name     = var.cluster_name
  location = var.zone # Zonal cluster = free tier (no management fee)

  # We manage node pools separately
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.gke.id
  subnetwork = google_compute_subnetwork.gke.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Minimize logging/monitoring costs
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = false
    }
  }

  # Allow deletion for cost management
  deletion_protection = false
}

# --- System Node Pool (always-on, 1 node) ---

resource "google_container_node_pool" "system" {
  name     = "system"
  location = var.zone
  cluster  = google_container_cluster.staging.name

  autoscaling {
    min_node_count = 0
    max_node_count = 1
  }

  node_config {
    machine_type = var.system_node_machine_type
    spot         = true

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      node-role = "system"
    }

    # Taint so only system pods schedule here
    taint {
      key    = "node-role"
      value  = "system"
      effect = "NO_SCHEDULE"
    }
  }
}

# --- Workload Node Pool (scale-to-zero) ---

resource "google_container_node_pool" "workload" {
  name     = "workload"
  location = var.zone
  cluster  = google_container_cluster.staging.name

  # Scale to zero when no workloads
  autoscaling {
    min_node_count = 0
    max_node_count = var.workload_node_max_count
  }

  node_config {
    machine_type = var.workload_node_machine_type
    spot         = true # Spot instances for lowest cost

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      node-role = "workload"
    }
  }
}

