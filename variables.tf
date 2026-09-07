variable "project_id" {
  description = "Existing GCP project ID to host the platform."
  type        = string
  default     = "learning-gke-498507"
}

variable "region" {
  description = "Regional control-plane and workload location."
  type        = string
  default     = "africa-south1"
}

variable "zones" {
  description = "Zones used by the regional GKE node pools."
  type        = list(string)
  default     = ["africa-south1-a", "africa-south1-b", "africa-south1-c"]
}

variable "name" {
  description = "Platform resource prefix."
  type        = string
  default     = "platform"
}

variable "github_org" {
  description = "GitHub organization or user that owns the application repository."
  type        = string
}

variable "github_repo" {
  description = "Application repository watched by Argo CD."
  type        = string
}

variable "github_manifest_repo" {
  description = "Repository updated by CI and watched by Argo CD."
  type        = string
}

variable "db_tier" {
  description = "Cloud SQL machine tier."
  type        = string
  default     = "db-custom-2-7680"
}

variable "node_machine_type" {
  description = "GKE node machine type."
  type        = string
  default     = "e2-standard-4"
}
