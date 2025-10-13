# Copilot Instructions - Azure Terraform Infrastructure Project

## Project Overview
This is a multi-environment Azure infrastructure project using Terraform to deploy core services:
- **Storage Account** with blob storage for Terraform state
- **Key Vault** for secrets management  
- **Resource Groups** for logical resource organization
- **RBAC** assignments for secure access control

## Architecture Patterns

### Environment Structure
- `environments/{dev,test,prod}/` - Environment-specific variable files (`.tfvars`)
- `backend/` - Separate Terraform configuration for backend storage infrastructure
- Root level - Main infrastructure configuration

### Naming Convention
Resources use a consistent pattern: `{resource-type}-{name_prefix}-{suffix}`
- Storage accounts: `st{name_prefix}{suffix}` (no hyphens due to Azure naming restrictions)
- Key vaults: `kv-{name_prefix}-{suffix}`
- Resource groups: `rg-{name_prefix}-{suffix}`

### Variable Override Pattern
The project implements a flexible naming system where environment variables can override default generated names:
```hcl
effective_suffix = var.unique_suffix != "" ? var.unique_suffix : random_string.auto_suffix[0].result
rg_final = var.resource_group_name != "" ? var.resource_group_name : "rg-${var.name_prefix}-${local.effective_suffix}"
```

## Key Configuration Differences by Environment

- **Dev**: Standard tier storage, LRS replication, unique_suffix="01"
- **Test**: Premium tier storage, LRS replication, unique_suffix="02" 
- **Prod**: Premium tier storage, GRS replication, premium Key Vault SKU, unique_suffix="03"

## Backend Configuration

### Two-Stage Setup
1. **Backend Infrastructure** (`backend/main.tf`): Creates the storage account and container for Terraform state
2. **Main Infrastructure** (`main.tf`): Uses the backend created in step 1 via `backend.hcl` configuration

### State Management
- Backend uses Azure Storage with `use_azuread_auth = true` for authentication
- Backend storage: Resource group `synnesda-iac-backend-rg`, storage account `synnesdaiacbackend`
- All environments share the same backend but use different state files (via `-backend-config` parameter)

## Security Model
- **RBAC-based**: Uses `enable_rbac_authorization = true` on Key Vault (not access policies)
- **Principal management**: Current user + optional `extra_principal_ids` get contributor access
- **Role assignments**: 
  - `Storage Blob Data Contributor` on state container
  - `Key Vault Secrets Officer` on Key Vault

## Critical Workflow Notes

### Deployment Pattern
1. First deploy backend infrastructure: `cd backend && terraform apply`
2. Then deploy main infrastructure with environment-specific backend config
3. Use PowerShell scripts in `scripts/deploy.ps1` for automation:
   - Should implement `terraform init -backend-config=environments/{env}/backend.hcl`
   - Should handle `terraform plan -var-file=environments/{env}/{env}.tfvars`
   - Should support environment parameter: `.\scripts\deploy.ps1 -Environment dev|test|prod`

### Variable Organization (Refactoring Needed)
- **Current**: All variables defined inline in `main.tf` (non-standard pattern)
- **Target**: Extract to proper `variables.tf` with descriptions and validation
- **Variables to extract**: `name_prefix`, `location`, `unique_suffix`, `subscription_id`, `container_name`, `account_tier`, `account_replication_type`, `kv_sku_name`, `resource_group_name`, `storage_account_name`, `kv_name`, `tags`, `extra_principal_ids`
- When adding new variables, follow standard Terraform structure in `variables.tf`

### Azure Provider Configuration
- Uses AzureRM provider ~> 4.40.0
- Requires CLI authentication (`use_cli = true`)
- Subscription ID is environment-specific via variables

## Development Guidelines

- Always test changes in `dev` environment first
- Use Norwegian regions (`Norway East`) consistently across environments
- Maintain the suffixing pattern when adding new resources
- Add RBAC assignments for any new security-sensitive resources
- Follow the environment-specific performance tiers (Standard vs Premium)