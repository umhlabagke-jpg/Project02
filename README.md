# Project02 production platform

Terraform and GitOps foundation for a private, regional GKE microservices platform on Google Cloud.

## Architecture

- Regional private GKE cluster with Dataplane V2, Workload Identity, shielded nodes, release channels, HPA support, and node auto-provisioning.
- Shared VPC with private GKE and Cloud SQL subnets, Private Google Access, Cloud NAT, and VPC flow logs.
- Regional Cloud SQL PostgreSQL with private IP, automated backups, point-in-time recovery, deletion protection, and CMEK-ready settings.
- Artifact Registry for images.
- Argo CD bootstrap manifests for an application repository and a separate environment manifest repository.
- GitHub Actions builds and publishes images, then updates the manifest repository.
- Google Managed Service for Prometheus and Cloud Monitoring SLO/alert hooks.

## Prerequisites

Terraform >= 1.6, Google Cloud CLI, kubectl, and Helm. Authenticate with `gcloud auth application-default login` and set a billing-enabled target project.

Copy `terraform.tfvars.example` to `terraform.tfvars`, set the GitHub repository values, then run:

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out platform.tfplan
terraform apply platform.tfplan
```

Terraform intentionally does not create a GCP project or GitHub repositories. Create the billing-enabled GCP project and the application/manifest repositories first, then set `project_id`, `github_org`, `github_repo`, and `github_manifest_repo`.

After apply, fetch credentials and install Argo CD:

```powershell
gcloud container clusters get-credentials platform --region europe-west1 --project learning-gke-498507
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.14.12/manifests/install.yaml
kubectl apply -f gitops/argocd/install.yaml
kubectl apply -f gitops/argocd/application.yaml
```

Do not commit `terraform.tfvars`, kubeconfig files, database passwords, or GitHub tokens. Use Secret Manager and GitHub Actions OIDC for runtime credentials.
