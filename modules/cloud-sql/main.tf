resource "google_sql_database_instance" "this" {
  project             = var.project_id
  name                = "${var.name}-postgres"
  region              = var.region
  database_version    = "POSTGRES_16"
  deletion_protection = true

  settings {
    tier              = var.database_tier
    availability_type = "REGIONAL"
    disk_type         = "PD_SSD"
    disk_size         = 100
    disk_autoresize   = true
    user_labels       = var.labels
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
    }
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network
      enable_private_path_for_google_cloud_services = true
    }
    insights_config {
      query_insights_enabled  = true
      query_plans_per_minute  = 5
      record_application_tags = true
      record_client_address   = false
    }
  }
}

resource "google_sql_database" "app" {
  project  = var.project_id
  name     = "app"
  instance = google_sql_database_instance.this.name
}
