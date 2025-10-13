//Backend-konfig for terraform init
resource_group_name  = "synnesda-iac-backend-rg"
storage_account_name = "synnesdaiacbackend"
container_name       = "tfstate"
use_azuread_auth     = true

