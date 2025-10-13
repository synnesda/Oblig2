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
| **prod**    | Standard | GRS | premium | High availability production |

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

## Assignment Requirements Fulfillment

### IaC Principles Implementation
✅ **Versioned Infrastructure**: All code stored in Git with full history tracking  
✅ **Traceability**: Every change tracked through commits and PR workflow  
✅ **Rapid Recertification**: Complete rebuild possible from code within minutes  
✅ **Environment Parity**: Same code deploys to all environments with different configuration  
✅ **Build Once, Deploy Many**: Single validated codebase deployed across dev/test/prod  
✅ **Trunk-based Development**: Feature branches → PR → main branch workflow  

### Multi-Environment Support
- **Development**: Standard/LRS for cost optimization
- **Test**: Premium/LRS for performance testing (prod-like performance)  
- **Production**: Standard/GRS for high availability as required

### Complete Deployment Workflow

#### 1. Local Development & Feature Branches
- Developers work locally and create feature branches
- Code pushed to GitHub triggers automated validation
- Pull Requests ensure code review before main branch

#### 2. Continuous Integration (CI)
- **Format Validation**: `terraform fmt -check -recursive`
- **Syntax Validation**: `terraform validate` 
- **Security Scanning**: Trivy vulnerability scanner
- **Multi-Environment Planning**: Plans generated for all environments
- **PR Comments**: Plan results posted for review

#### 3. Continuous Deployment (CD)  
- **Dev Environment**: Auto-deployed on develop branch
- **Test Environment**: Auto-deployed after dev success on main
- **Production**: Manual approval required for production deployments

### Team Collaboration Features
- **No Merge Conflicts**: Separate state files per environment
- **Parallel Development**: Backend state locking prevents conflicts
- **Automated Workflows**: Reduces manual deployment errors
- **Environment Protection**: GitHub environment protections for prod

## Security Features

- **RBAC Authorization** on Key Vault (no access policies)
- **HTTPS-only** storage accounts
- **Private containers** for state storage
- **Blob versioning** and retention policies
- **Soft delete protection** on Key Vault
- **Federated Credentials** for GitHub Actions authentication

## Naming Convention

Resources follow the pattern: `{type}-{prefix}-{suffix}`
- Resource Groups: `rg-{prefix}-{suffix}`  
- Storage Accounts: `st{prefix}{suffix}` (no hyphens, Azure naming restrictions)
- Key Vaults: `kv-{prefix}-{suffix}`

## Infrastructure Components

### Required Components (Per Assignment)
✅ **Resource Group**: Logical organization of resources  
✅ **Storage Account**: Data storage with tier-appropriate configuration  
✅ **Key Vault**: Secrets management (additional security enhancement)

### Terraform Best Practices
- **Input Variables**: Comprehensive variable definitions with validation
- **Local Values**: Smart naming logic and resource calculations  
- **Environment Configuration**: Separate .tfvars for each environment
- **Backend State Management**: Remote state with Azure Storage
- **Provider Consistency**: Locked provider versions across environments

## Recommended Deployment Workflow

### 1. Development First (Always start here)
```powershell
# Deploy to dev for testing
.\scripts\deploy.ps1 -Environment dev -Apply

# Verify everything works
# Make any necessary adjustments
```

### 2. Test Environment (Performance validation)
```powershell
# Deploy same code to test environment
.\scripts\deploy.ps1 -Environment test -Apply

# Validate performance with Premium storage
# Ensure prod-like behavior
```

### 3. Production Deployment (Final step)
```powershell
# Deploy to production with high availability
.\scripts\deploy.ps1 -Environment prod -Apply

# Monitor deployment
# Verify GRS replication is working
```

### 4. Cleanup (When done)
```powershell
# Clean up in reverse order
.\scripts\deploy.ps1 -Environment prod -Destroy
.\scripts\deploy.ps1 -Environment test -Destroy  
.\scripts\deploy.ps1 -Environment dev -Destroy
```

## Complete Deployment Flow

### Step 1: Local Development
```bash
# Create feature branch
git checkout -b feature/new-infrastructure

# Develop locally
terraform init -backend-config=environments/dev/backend.hcl
terraform plan -var-file=environments/dev/dev.tfvars

# Commit and push
git add .
git commit -m "Add new infrastructure component"
git push origin feature/new-infrastructure
```

### Step 2: Pull Request & CI
1. Create PR against main branch
2. CI pipeline automatically runs:
   - Format check (`terraform fmt`)
   - Validation (`terraform validate`)
   - Security scan (Trivy)
   - Multi-environment planning
3. Plan results posted as PR comment
4. Code review and approval
5. Merge to main

### Step 3: Automated Deployment
```
main branch merge → Test Environment → Production (manual approval)
```

### Step 4: Manual Operations (if needed)
Use GitHub Actions manual dispatch for:
- Emergency deployments
- Environment-specific operations  
- Infrastructure destruction

## File Structure Explanation

```
.
├── .github/
│   └── workflows/
│       └── ci-cd.yaml           # Complete CI/CD pipeline
├── backend/
│   ├── main.tf                  # Backend storage infrastructure
│   └── backend.hcl              # Backend configuration
├── environments/
│   ├── dev/
│   │   ├── dev.tfvars          # Dev environment configuration
│   │   └── backend.hcl         # Dev backend config
│   ├── test/
│   │   ├── test.tfvars         # Test environment configuration  
│   │   └── backend.hcl         # Test backend config
│   └── prod/
│       ├── prod.tfvars         # Prod environment configuration
│       └── backend.hcl         # Prod backend config
├── scripts/
│   └── deploy.ps1              # PowerShell deployment automation
├── main.tf                     # Main infrastructure code
├── variables.tf                # Input variable definitions
├── locals.tf                   # Local value calculations  
├── outputs.tf                  # Infrastructure outputs
└── README.md                   # This documentation
```

## Key Learning Outcomes

This project demonstrates:
1. **IaC Principles**: Infrastructure as Code best practices
2. **Multi-Environment Management**: dev/test/prod configuration
3. **CI/CD Implementation**: Automated testing and deployment
4. **Security**: RBAC, secret management, vulnerability scanning
5. **Team Collaboration**: Trunk-based development, PR workflow
6. **Azure Integration**: Native Azure services and authentication