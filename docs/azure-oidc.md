# Configure Azure Workload Identity Federation for GitHub Actions

This document shows minimal `az` CLI commands to create a service principal and a federated identity credential that allows GitHub Actions to request short-lived tokens (OIDC) and authenticate to Azure without storing long-lived secrets.

Prerequisites
- Azure CLI installed and you're signed in (`az login`).
- You have Owner or Application Administrator rights to register federated credentials on the service principal.

1) Create a service principal (or reuse an existing one)

```powershell
az ad sp create-for-rbac --name "http://github-actions-sp-ssd" --role Contributor --scopes /subscriptions/<SUBSCRIPTION_ID>
```

Note the output `appId` (client id). Save `subscriptionId` and `tenantId` too.

2) Create a federated identity credential on the service principal

Replace `<TENANT_ID>`, `<APP_OBJECT_ID>`, `<REPO>`, and `<OWNER>` accordingly.

```powershell
# Get the service principal's object id
$sp = az ad sp show --id <APP_ID> --query "{id:objectId,appId:appId,displayName:displayName}" | ConvertFrom-Json
$objectId = $sp.id

# Create federated credential JSON body
$body = @{
  name = "github-actions-ssd-fx"
  issuer = "https://token.actions.githubusercontent.com"
  subject = "repo:<OWNER>/<REPO>:ref:refs/heads/main"
  description = "Federated credential for GitHub Actions workflow"
  audiences = @("api://AzureADTokenExchange")
} | ConvertTo-Json -Depth 10

# Use the Microsoft Graph API to create the federated identity credential
# Requires 'application' permission to update the app; you may need to use az rest with proper permissions
az rest --method POST --uri "https://graph.microsoft.com/v1.0/applications/$objectId/federatedIdentityCredentials" --body $body
```

Notes:
- `subject` can be tailored for finer-grained trust: use `repo:<OWNER>/<REPO>:environment:<environment>` or `repo:<OWNER>/<REPO>:ref:refs/heads/<branch>`.
- After this is configured, you can remove the `AZURE_CREDENTIALS` secret from GitHub and rely on the OIDC login in the workflow.

3) Add required GitHub repository secrets
- `AZURE_CLIENT_ID` = service principal appId
- `AZURE_SUBSCRIPTION_ID` = your subscription id
- `AZURE_TENANT_ID` = tenant id

4) Validate from GitHub Actions
- Ensure the workflow has `permissions: id-token: write` at the workflow or job level.
- Run a workflow that uses `azure/login@v2` with `client-id`, `tenant-id`, and `subscription-id`. The action will request an OIDC token and exchange it for Azure credentials.

References
- https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect
- https://github.com/Azure/login
