resource "google_container_cluster" "this" {
  provider                    = google-beta
  project                     = var.project_id
  name                        = var.name
  location                    = var.region
  network                     = var.network
  subnetwork                  = var.subnetwork
  node_locations              = var.zones
  networking_mode             = "VPC_NATIVE"
  datapath_provider           = "ADVANCED_DATAPATH"
  enable_l4_ilb_subsetting    = true
  deletion_protection         = true
  enable_shielded_nodes       = true
  enable_intranode_visibility = true
  initial_node_count          = 1

  release_channel { channel = "REGULAR" }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_authorized_networks_config {
    gcp_public_cidrs_access_enabled = false
  }

  workload_identity_config { workload_pool = "${var.project_id}.svc.id.goog" }
  vertical_pod_autoscaling { enabled = true }
  monitoring_config {
    managed_prometheus { enabled = true }
    advanced_datapath_observability_config {
      enable_metrics = true
      enable_relay   = true
    }
  }
  logging_config { enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS", "APISERVER"] }
  addons_config {
    http_load_balancing { disabled = false }
    horizontal_pod_autoscaling { disabled = false }
    gcs_fuse_csi_driver_config { enabled = true }
  }
}

resource "google_container_node_pool" "system" {
  project    = var.project_id
  name       = "system"
  location   = var.region
  cluster    = google_container_cluster.this.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  upgrade_settings {
    strategy        = "SURGE"
    max_surge       = 1
    max_unavailable = 0
  }

  node_config {
    machine_type    = var.node_machine_type
    service_account = var.node_service_account
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    image_type      = "COS_CONTAINERD"
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
    workload_metadata_config { mode = "GKE_METADATA" }
    labels = var.labels
    tags   = ["${var.name}-gke"]
  }
}
