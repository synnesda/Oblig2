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
```powershell
# Plan deployment
.\scripts\deploy.ps1 -Environment dev

# Apply deployment  
.\scripts\deploy.ps1 -Environment dev -Apply

# Destroy resources
.\scripts\deploy.ps1 -Environment dev -Destroy
```

## Environments

| Environment | Tier | Replication | Key Vault SKU | Suffix |
|-------------|------|-------------|---------------|--------|
| **dev**     | Standard | LRS | standard | 01 |
| **test**    | Premium | LRS | standard | 02 |
| **prod**    | Premium | GRS | premium | 03 |

## Project Structure

```
├── main.tf              # Main infrastructure configuration
├── variables.tf         # Variable definitions with validation
├── outputs.tf           # Infrastructure outputs
├── locals.tf           # Local value calculations
├── backend/            # Backend state storage setup
│   ├── main.tf
│   └── backend.hcl
├── environments/       # Environment-specific configurations
│   ├── dev/
│   │   ├── dev.tfvars
│   │   └── backend.hcl
│   ├── test/
│   └── prod/
└── scripts/
    └── deploy.ps1      # PowerShell deployment automation
```

## Security Features

- **RBAC Authorization** on Key Vault (no access policies)
- **HTTPS-only** storage accounts
- **Private containers** for state storage
- **Blob versioning** and retention policies
- **Soft delete protection** on Key Vault

## Naming Convention

Resources follow the pattern: `{type}-{prefix}-{suffix}`
- Resource Groups: `rg-{prefix}-{suffix}`  
- Storage Accounts: `st{prefix}{suffix}` (no hyphens)
- Key Vaults: `kv-{prefix}-{suffix}`