# Azure Terraform Infrastructure Project

This project deploys core Azure infrastructure across multiple environments (dev, test, prod) using Terraform.

## Architecture

- **Resource Group** - Logical container for all resources
- **Storage Account** - Blob storage with Terraform state management
- **Key Vault** - Secrets management with RBAC authorization
- **RBAC Assignments** - Secure access control for resources

## Quick Start

### Prerequisites
- Azure CLI installed and authenticated (`az login`)
- Terraform >= 1.6.0 installed
- PowerShell (for deployment scripts)

### 1. Deploy Backend Infrastructure
```bash
cd backend
terraform init
terraform apply
```

### 2. Deploy Environment Infrastructure

#### Development Environment
```powershell
# Plan deployment
.\scripts\deploy.ps1 -Environment dev

# Apply deployment  
.\scripts\deploy.ps1 -Environment dev -Apply

# Destroy resources
.\scripts\deploy.ps1 -Environment dev -Destroy
```

#### Test Environment
```powershell
# Plan deployment
.\scripts\deploy.ps1 -Environment test

# Apply deployment  
.\scripts\deploy.ps1 -Environment test -Apply

# Destroy resources
.\scripts\deploy.ps1 -Environment test -Destroy
```

#### Production Environment
```powershell
# Plan deployment
.\scripts\deploy.ps1 -Environment prod

# Apply deployment  
.\scripts\deploy.ps1 -Environment prod -Apply

# Destroy resources (BE CAREFUL!)
.\scripts\deploy.ps1 -Environment prod -Destroy
```

#### Alternative: Direct Terraform Commands
```bash
# For any environment (replace 'dev' with 'test' or 'prod')
terraform init -backend-config="environments/dev/backend.hcl" -reconfigure
terraform plan -var-file="environments/dev/dev.tfvars"
terraform apply -var-file="environments/dev/dev.tfvars"
terraform destroy -var-file="environments/dev/dev.tfvars"
```

## Environments

| Environment | Tier | Replication | Key Vault SKU | Description |
|-------------|------|-------------|---------------|-------------|
| **dev**     | Standard | LRS | standard | Cost-effective development |
| **test**    | Premium | LRS | standard | Performance testing (prod-like) |
| **prod**    | Premium | GRS | premium | High availability production |

## Project Structure
## Azure Terraform Infrastructure Project

This repository deploys core Azure infrastructure across multiple environments (dev, test, prod) using Terraform. It includes a platform-owned Resource Group module and a CI pipeline with OIDC authentication, security scans, and PR plan comments.

## What's new (recent changes)
- CI now requires GitHub OIDC (workload identity federation) with `azure/login@v2`. Legacy service-principal secret fallback has been removed.
- Terraform provider lockfile: `.terraform.lock.hcl` is committed for reproducible provider versions.
- Static security scanning added: `tfsec` runs in CI and now fails the job on findings.
- Plan artifacts are uploaded and plan outputs are posted as PR comments (plan-commenter action).
- `docs/azure-oidc.md` added with step-by-step instructions to create the federated credential in Azure.

## Architecture

- Resource Group (platform-owned via `modules/platform`)
- Storage Account for Terraform state (one container per environment)
- Key Vault using RBAC authorization (no access policies)
- Role assignments for state and Key Vault operations

## Quick Start

### Prerequisites
- Azure CLI (az) and logged in (`az login`)
- Terraform >= 1.6.0
- PowerShell (optional; `scripts/deploy.ps1` is PowerShell)

### 1) Create backend resources (once)
```powershell
cd backend
terraform init
terraform apply
```

### 2) Deploy an environment (example: dev)
```powershell
# Plan
.\scripts\deploy.ps1 -Environment dev

# Apply
.\scripts\deploy.ps1 -Environment dev -Apply

# Destroy
.\scripts\deploy.ps1 -Environment dev -Destroy
```

Alternative: use terraform directly per environment
```powershell
terraform init -backend-config="environments/dev/backend.hcl" -reconfigure
terraform plan -var-file="environments/dev/dev.tfvars"
terraform apply -var-file="environments/dev/dev.tfvars"
```

## CI / GitHub Actions

- The workflow is at `.github/workflows/ci-cd.yaml` and runs:
  - `terraform fmt` and `terraform validate`
  - Trivy config scan
  - `tfsec` (static security checks) — CI will fail on findings
  - Per-environment `terraform plan` with plan artifacts uploaded
  - PR plan-comments using `peter-evans/create-or-update-comment`
  - Manual approval step before production apply

Important: configure OIDC before running CI. See `docs/azure-oidc.md`.

## Security notes

- Key Vault uses RBAC (`enable_rbac_authorization = true`).
- State is stored in a private blob container with role assignments for `Storage Blob Data Contributor`.
- `tfsec` runs in CI and will fail the job for issues — triage or fix findings before merge.

## How to configure OIDC (short)

Follow `docs/azure-oidc.md` for exact `az`/`az rest` commands. In short:
1. Create (or reuse) a service principal and note `appId` (client id) and `objectId`.
2. Add a federated identity credential to the app with subject `repo:<OWNER>/<REPO>:ref:refs/heads/<branch>` or `repo:<OWNER>/<REPO>:environment:<environment>`.
3. Add repo secrets: `AZURE_CLIENT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID`.

## Project structure

```
. 
├── .github/
│   └── workflows/
│       └── ci-cd.yaml        # CI pipeline (OIDC, tfsec, trivy, plan commenter)
├── backend/                  # Backend infra for Terraform state
├── docs/
│   └── azure-oidc.md         # OIDC/federated credential setup
├── environments/             # dev/test/prod .tfvars + backend configs
├── modules/
│   └── platform/             # platform module which owns the Resource Group
├── scripts/
│   └── deploy.ps1            # PowerShell deployment helper
├── main.tf                   # Root module wiring resources and calling modules
├── variables.tf
├── locals.tf
├── outputs.tf
└── .terraform.lock.hcl       # Provider lockfile (committed)
```

## Common commands

```powershell
# create provider lockfile (done in repo)
terraform providers lock -platform=linux_amd64 -platform=windows_amd64 -platform=darwin_amd64

# plan for dev
terraform init -backend-config="environments/dev/backend.hcl" -reconfigure
terraform plan -var-file="environments/dev/dev.tfvars"

# run tfsec locally
tfsec .
```

## Final checklist before submission

- OIDC federated credential created in Azure and repo secrets set
- CI run succeeds (trivy + tfsec + format/validate + plan)
- `.terraform.lock.hcl` committed (done)
- PR plan comments appear on PRs (enabled)

If you want, I can draft a short submission note that explains the security improvements and highlights the items tested. Paste any tfsec findings here and I will help triage them.