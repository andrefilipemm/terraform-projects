output "resourcegroup" {
  value = azurerm_resource_group.resource-group
}

output "resource_group_name" {
  value = azurerm_resource_group.resource-group.name
}

output "resource_group_location" {
  value = azurerm_resource_group.resource-group.location
}
