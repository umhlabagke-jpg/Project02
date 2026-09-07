init:
	terraform init

validate:
	terraform fmt -check -recursive
	terraform validate

plan:
	terraform plan -out platform.tfplan

security-scan:
	trivy config .
