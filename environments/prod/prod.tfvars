name_prefix              = "ssd-prod"
location                 = "Norway East"
unique_suffix            = ""
subscription_id          = "a3adf20e-4966-4afb-b717-4de1baae6db1"
container_name           = "ssd-tfstate"
account_tier             = "Standard" # Must use Standard for GRS support
account_replication_type = "GRS"      # High availability as per requirements
kv_sku_name              = "premium"
resource_group_name      = ""
storage_account_name     = ""
kv_name                  = ""
tags = {
  environment = "prod"
}
extra_principal_ids = []
