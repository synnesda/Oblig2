param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "test", "prod")]
    [string]$Environment,
    
    [switch]$Plan,
    [switch]$Apply,
    [switch]$Destroy
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Get the script directory and project root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "🚀 Terraform Deployment Script" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Cyan

# Set paths
$EnvironmentDir = Join-Path $ProjectRoot "environments\$Environment"
$BackendConfigFile = Join-Path $EnvironmentDir "backend.hcl"
$VarsFile = Join-Path $EnvironmentDir "$Environment.tfvars"

# Validate files exist
if (-not (Test-Path $VarsFile)) {
    Write-Error "Variables file not found: $VarsFile"
    exit 1
}

if (-not (Test-Path $BackendConfigFile)) {
    Write-Error "Backend config file not found: $BackendConfigFile"
    exit 1
}

try {
    # Change to project root
    Push-Location $ProjectRoot
    
    # Initialize Terraform with backend config
    Write-Host "📋 Initializing Terraform with backend configuration..." -ForegroundColor Yellow
    terraform init -backend-config="$BackendConfigFile" -reconfigure
    
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform init failed"
    }
    
    # Validate configuration
    Write-Host "✅ Validating Terraform configuration..." -ForegroundColor Yellow
    terraform validate
    
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform validate failed"
    }
    
    # Execute based on parameters
    if ($Plan -or (-not $Apply -and -not $Destroy)) {
        Write-Host "📊 Creating Terraform plan..." -ForegroundColor Yellow
        terraform plan -var-file="$VarsFile" -out="terraform-$Environment.tfplan"
        
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform plan failed"
        }
    }
    
    if ($Apply) {
        Write-Host "🚀 Applying Terraform configuration..." -ForegroundColor Yellow
        if (Test-Path "terraform-$Environment.tfplan") {
            terraform apply "terraform-$Environment.tfplan"
        } else {
            terraform apply -var-file="$VarsFile"
        }
        
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform apply failed"
        }
        
        Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
    }
    
    if ($Destroy) {
        Write-Host "⚠️  WARNING: This will destroy all resources in $Environment environment!" -ForegroundColor Red
        $confirmation = Read-Host "Type 'yes' to confirm destruction"
        
        if ($confirmation -eq 'yes') {
            terraform destroy -var-file="$VarsFile"
            
            if ($LASTEXITCODE -ne 0) {
                throw "Terraform destroy failed"
            }
            
            Write-Host "💥 Resources destroyed successfully!" -ForegroundColor Green
        } else {
            Write-Host "❌ Destruction cancelled" -ForegroundColor Yellow
        }
    }
    
} catch {
    Write-Error "Deployment failed: $_"
    exit 1
} finally {
    Pop-Location
}

Write-Host "🎉 Script completed!" -ForegroundColor Green