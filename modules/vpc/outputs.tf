output "network_name" { value = google_compute_network.this.name }
output "network_self_link" { value = google_compute_network.this.self_link }
output "gke_subnetwork_name" { value = google_compute_subnetwork.gke.name }
