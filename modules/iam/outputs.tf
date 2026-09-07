output "workload_identity_service_account" { value = google_service_account.workload_identity.email }
output "github_actions_service_account" { value = google_service_account.github_actions.email }
output "github_workload_identity_provider" { value = google_iam_workload_identity_pool.github.name }
