locals {
  # Generate effective suffix - use provided suffix or generate random one
  effective_suffix = var.unique_suffix != "" ? var.unique_suffix : tostring(random_integer.auto_suffix[0].result)
  
  # Final resource names with override capability
  rg_final = var.resource_group_name != "" ? var.resource_group_name : "rg-${var.name_prefix}-${local.effective_suffix}"
  sa_final = var.storage_account_name != "" ? var.storage_account_name : "st${var.name_prefix}${local.effective_suffix}"
  kv_final = var.kv_name != "" ? var.kv_name : "kv-${var.name_prefix}-${local.effective_suffix}"
  
  # Combine current user with extra principals for RBAC assignments
  principals = toset(concat([data.azurerm_client_config.current.object_id], var.extra_principal_ids))
}