variable "name_prefix" {
  description = "Prefix used for naming all resources"
  type        = string
  validation {
    condition     = length(var.name_prefix) >= 2 && length(var.name_prefix) <= 10
    error_message = "The name_prefix must be between 2 and 10 characters."
  }
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "Norway East"
  validation {
    condition = contains([
      "Norway East", "Norway West", "West Europe", "North Europe"
    ], var.location)
    error_message = "Location must be a supported Norwegian or European region."
  }
}

variable "unique_suffix" {
  description = "Unique suffix for resource names. If empty, a random suffix will be generated."
  type        = string
  default     = ""
  validation {
    condition     = var.unique_suffix == "" || (length(var.unique_suffix) >= 2 && length(var.unique_suffix) <= 6)
    error_message = "The unique_suffix must be empty or between 2 and 6 characters."
  }
}

variable "subscription_id" {
  description = "Azure subscription ID where resources will be deployed"
  type        = string
  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id))
    error_message = "The subscription_id must be a valid GUID format."
  }
}

variable "container_name" {
  description = "Name of the storage container for Terraform state"
  type        = string
  default     = "tfstate"
}

variable "account_tier" {
  description = "Storage account performance tier"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either 'Standard' or 'Premium'."
  }
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
  validation {
    condition = contains([
      "LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"
    ], var.account_replication_type)
    error_message = "Account replication type must be a valid Azure storage replication option."
  }
}

variable "kv_sku_name" {
  description = "Key Vault SKU name"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.kv_sku_name)
    error_message = "Key Vault SKU must be either 'standard' or 'premium'."
  }
}

variable "resource_group_name" {
  description = "Override for resource group name. If empty, will use generated name based on prefix and suffix."
  type        = string
  default     = ""
}

variable "storage_account_name" {
  description = "Override for storage account name. If empty, will use generated name based on prefix and suffix."
  type        = string
  default     = ""
  validation {
    condition = var.storage_account_name == "" || (
      length(var.storage_account_name) >= 3 && 
      length(var.storage_account_name) <= 24 && 
      can(regex("^[a-z0-9]+$", var.storage_account_name))
    )
    error_message = "Storage account name must be 3-24 characters long and contain only lowercase letters and numbers."
  }
}

variable "kv_name" {
  description = "Override for Key Vault name. If empty, will use generated name based on prefix and suffix."
  type        = string
  default     = ""
  validation {
    condition = var.kv_name == "" || (
      length(var.kv_name) >= 3 && 
      length(var.kv_name) <= 24 && 
      can(regex("^[a-zA-Z0-9-]+$", var.kv_name))
    )
    error_message = "Key Vault name must be 3-24 characters long and contain only alphanumeric characters and hyphens."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "extra_principal_ids" {
  description = "Additional Azure AD principal IDs to grant access to Key Vault and Storage"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for id in var.extra_principal_ids : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", id))
    ])
    error_message = "All extra_principal_ids must be valid GUID format."
  }
}