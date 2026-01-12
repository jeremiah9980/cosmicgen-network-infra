# Proxmox Terraform (CosmicGen)

Terraform project to provision VMs in Proxmox using API tokens.

## Proxmox Endpoint
Management URL:
https://47.163.25.30:8006/api2/json

## Prerequisites
- Terraform >= 1.5
- Proxmox API Token
- Cloud-init enabled template VM

## Usage

1. Copy example vars:
```bash
cp examples/terraform.tfvars.example terraform.tfvars
```

2. Export API credentials (recommended):
```bash
export TF_VAR_pm_api_url="https://47.163.25.30:8006/api2/json"
export TF_VAR_pm_api_token_id="terraform@pve!tf"
export TF_VAR_pm_api_token_secret="REPLACE_ME"
```

3. Initialize and deploy:
```bash
terraform init
terraform plan
terraform apply
```
