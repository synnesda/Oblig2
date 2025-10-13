output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.rg.id
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = azurerm_storage_account.sa.name
}

output "storage_account_id" {
  description = "ID of the created storage account"
  value       = azurerm_storage_account.sa.id
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.sa.primary_blob_endpoint
}

output "storage_container_name" {
  description = "Name of the Terraform state container"
  value       = azurerm_storage_container.state.name
}

output "key_vault_name" {
  description = "Name of the created Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_id" {
  description = "ID of the created Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_uri" {
  description = "URI of the created Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

output "effective_suffix" {
  description = "The actual suffix used for resource naming (generated or provided)"
  value       = local.effective_suffix
}

output "principals_with_access" {
  description = "List of principal IDs that have been granted access to resources"
  value       = tolist(local.principals)
  sensitive   = true
}

output "deployment_info" {
  description = "Summary of deployed resources"
  value = {
    environment           = var.tags.environment
    resource_group       = azurerm_resource_group.rg.name
    storage_account      = azurerm_storage_account.sa.name
    key_vault           = azurerm_key_vault.kv.name
    location            = var.location
    suffix_used         = local.effective_suffix
  }
}