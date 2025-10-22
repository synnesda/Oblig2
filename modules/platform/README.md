Platform module
----------------

Creates a Resource Group and returns its name and id.

Usage example:

module "platform" {
  source   = "../../modules/platform"
  name     = "rg-example"
  location = "norwayeast"
  tags     = { environment = "dev" }
}
