name_prefix              = "ssd-test"
location                 = "Norway East"
unique_suffix            = ""
subscription_id          = "a3adf20e-4966-4afb-b717-4de1baae6db1"
container_name           = "ssd-tfstate"
account_tier             = "Premium" # Litt som prod
account_replication_type = "LRS"     # Test ligner på prod, men kan bruke LRS
kv_sku_name              = "standard"
resource_group_name      = ""
storage_account_name     = ""
kv_name                  = ""
tags = {
  environment = "test"
}
extra_principal_ids = []
