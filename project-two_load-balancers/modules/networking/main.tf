module "rg-module" {
  source   = ".././modules/resource-group"
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "appnetwork" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]
  depends_on = [
    module.rg-module.resourcegroup
  ]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 0)]
  depends_on = [
    azurerm_virtual_network.appnetwork
  ]
}

resource "azurerm_network_security_group" "appnsg" {
  name                = "app-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_virtual_network.appnetwork
  ]
}

resource "azurerm_network_security_rule" "nsg-rules" {
  for_each                    = { for rule in var.network_security_group_rules : rule.id => rule }
  name                        = "Allow-${each.value.suffix}"
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appnsg.name
  depends_on = [
    module.resource-group-module.resourcegroup,
    azurerm_network_security_group.nsg
  ]
}
