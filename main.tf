terraform {
  required_version = ">= 1.6.0"

  backend "azurerm" {
    # config via backend.hcl + CLI key
  }

  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.40.0" }
    random  = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  use_cli         = true
}

data "azurerm_client_config" "current" {}

# Random suffix for unique names (numbers only)
resource "random_integer" "auto_suffix" {
  min   = 100000
  max   = 999999
  count = var.unique_suffix == "" ? 1 : 0
}

# Locals moved to locals.tf for better organization

resource "azurerm_resource_group" "rg" {
  name     = local.rg_final
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "sa" {
  name                     = local.sa_final
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  identity { type = "SystemAssigned" }

  blob_properties {
    versioning_enabled = var.account_tier == "Standard" ? true : false
    delete_retention_policy { days = 14 }
    container_delete_retention_policy { days = 14 }
  }

  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  tags                            = var.tags
}

resource "azurerm_storage_container" "state" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

resource "azurerm_key_vault" "kv" {
  name                          = local.kv_final
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = var.kv_sku_name
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  enable_rbac_authorization     = true
  public_network_access_enabled = false
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
  tags                          = var.tags
}

resource "azurerm_role_assignment" "sa_blob_contributor" {
  for_each             = local.principals
  scope                = azurerm_storage_container.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "kv_secrets_officer" {
  for_each             = local.principals
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = each.key
}
