locals {
  labels = {
    environment = "prod"
    managed-by  = "terraform"
    platform    = var.name
  }
}

resource "google_project_service" "apis" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

module "vpc" {
  source     = "./modules/vpc"
  name       = var.name
  project_id = var.project_id
  region     = var.region
  labels     = local.labels
  depends_on = [google_project_service.apis]
}

module "iam" {
  source      = "./modules/iam"
  name        = var.name
  project_id  = var.project_id
  labels      = local.labels
  github_org  = var.github_org
  github_repo = var.github_repo
}

module "gke" {
  source               = "./modules/gke"
  name                 = var.name
  project_id           = var.project_id
  region               = var.region
  zones                = var.zones
  network              = module.vpc.network_name
  subnetwork           = module.vpc.gke_subnetwork_name
  node_machine_type    = var.node_machine_type
  workload_identity_sa = module.iam.workload_identity_service_account
  labels               = local.labels
  depends_on           = [google_project_service.apis]
}

module "cloud_sql" {
  source        = "./modules/cloud-sql"
  name          = var.name
  project_id    = var.project_id
  region        = var.region
  network       = module.vpc.network_self_link
  database_tier = var.db_tier
  labels        = local.labels
  depends_on    = [google_project_service.apis]
}

resource "google_artifact_registry_repository" "containers" {
  project       = var.project_id
  location      = var.region
  repository_id = "${var.name}-containers"
  description   = "Production container images"
  format        = "DOCKER"
  labels        = local.labels
  depends_on    = [google_project_service.apis]
}

resource "google_monitoring_service" "application" {
  service_id   = "${var.name}-application"
  display_name = "${var.name} application"
  project      = var.project_id
}

resource "google_monitoring_slo" "availability" {
  service         = google_monitoring_service.application.service_id
  slo_id          = "availability"
  display_name    = "99.9% availability"
  goal            = 0.999
  calendar_period = "MONTH"

  request_based_sli {
    distribution_cut {
      distribution_filter = "metric.type=\"loadbalancing.googleapis.com/https/request_latencies\" resource.type=\"https_lb_rule\""
      range {
        max = 1000
      }
    }
  }
}
