resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.location
  tags     = var.tags
}

output "name" {
  value = azurerm_resource_group.rg.name
}

output "id" {
  value = azurerm_resource_group.rg.id
}
