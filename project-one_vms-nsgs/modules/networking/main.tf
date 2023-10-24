module "resource-group-module" {
  source              = ".././resource-group"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Virtual Network

resource "azurerm_virtual_network" "network" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.virtual_network_address_space]
  depends_on = [
    module.resource-group-module.resourcegroup
  ]
}

# Subnets within the Virtual Network

resource "azurerm_subnet" "subnets" {
  for_each             = toset(var.subnet_names)
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(var.virtual_network_address_space, 8, index(var.subnet_names, each.key))] # cidrsubnet(prefix, newbits, netnum)
  depends_on = [
    azurerm_virtual_network.network
  ]
}

# Network Security Group

resource "azurerm_network_security_group" "nsg" {
  for_each            = var.network_security_group_names
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_virtual_network.network
  ]
}

resource "azurerm_network_security_rule" "nsg-rules" {
  for_each                    = { for rule in var.network_security_group_rules : rule.id => rule }
  name                        = "${each.value.access}-${each.value.destination_port_range}"
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg[each.value.network_security_group_name].name
  depends_on = [
    module.resource-group-module.resourcegroup,
    azurerm_network_security_group.nsg
  ]
}

resource "azurerm_subnet_network_security_group_association" "nsg-link" {
  for_each                  = var.network_security_group_names
  subnet_id                 = azurerm_subnet.subnets[each.value].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id

  depends_on = [
    azurerm_virtual_network.network,
    azurerm_network_security_group.nsg
  ]
}

# We may have a Azure Bastion service

resource "azurerm_subnet" "bastion-subnet" {
  count                = var.bastion_required ? 1 : 0 # if bastion_required = true -> run the block once / else don't run the block at all
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.0.10.0/24"]
  depends_on = [
    azurerm_virtual_network.network
  ]
}

resource "azurerm_public_ip" "bastion-ip" {
  count               = var.bastion_required ? 1 : 0
  name                = "bastion-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [
    module.resource-group-module.resourcegroup
  ]
}

resource "azurerm_bastion_host" "app-bastion" {
  count               = var.bastion_required ? 1 : 0
  name                = "app-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion-subnet[0].id
    public_ip_address_id = azurerm_public_ip.bastion-ip[0].id
  }
}
