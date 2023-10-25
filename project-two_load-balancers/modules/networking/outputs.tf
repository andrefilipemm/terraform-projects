output "subnet" {
  value = azurerm_subnet.subnet
}

output "virtual_network_name" {
  value = azurerm_virtual_network.appnetwork.name
}

output "address_space" {
  value = azurerm_virtual_network.appnetwork.address_space
}

output "network_security_group_rules" {
  value = azurerm_network_security_rule.nsg-rules
  
}