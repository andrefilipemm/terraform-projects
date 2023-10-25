# Load Balancer dependent resource modules

module "rg-module" {
  source              = "./modules/resource-group"
  resource_group_name = "project-two-resource-group"
  location            = "West Europe"
}

module "networking-module" {
  source               = "./modules/networking"
  resource_group_name  = module.rg-module.resource_group_name
  location             = module.rg-module.resource_group_location
  virtual_network_name = "app-network"
  address_space        = "10.0.0.0/16"
  network_security_group_rules = [
    {
      id                     = 1
      suffix                 = "RDP"
      priority               = 300
      destination_port_range = 3389
    },
    {
      id                     = 2
      suffix                 = "HTTP"
      priority               = 400
      destination_port_range = 80
    }
  ]
}

module "vm-module" {
  source                       = "./modules/virtual-machines"
  resource_group_name          = module.rg-module.resource_group_name
  location                     = module.rg-module.resource_group_location
  virtual_network_name         = module.networking-module.virtual_network_name
  address_space                = module.networking-module.virtual_network_address_space
  network_security_group_rules = module.networking-module.network_security_group_rules
  number_vms                   = 2
  availability_set_required    = true
}

# Implementation of Load Balancer

resource "azurerm_public_ip" "loadip" {
  name                = local.load_ip_name
  resource_group_name = module.rg-module.resource_group_name
  location            = module.rg-module.resource_group_location
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [
    module.rg-module.resource-group
  ]
}

resource "azurerm_lb" "appbalancer" {
  name                = local.app_balancer_name
  location            = module.rg-module.resource_group_location
  resource_group_name = module.rg-module.resource_group_name
  sku                 = "Standard"
  sku_tier            = "Regional"
  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.loadip.id
  }
  depends_on = [
    azurerm_public_ip.loadip
  ]
}

resource "azurerm_lb_backend_address_pool" "pool_address" {
  loadbalancer_id = azurerm_lb.appbalancer.id
  name            = local.pool_address_name
  depends_on = [
    azurerm_lb.appbalancer
  ]
}

resource "azurerm_lb_backend_address_pool_address" "appvmaddress" {
  count                   = module.virtual-machines.number_vms
  name                    = "appvm${count.index + 1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool_address.id
  virtual_network_id      = module.networking-module.network.id
  ip_address              = module.vm-module.network_interface[count.index].private_ip_address
  depends_on = [
    azurerm_lb_backend_address_pool.pool_address,
    module.vm-module.network_interface
  ]
}

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.appbalancer.id
  name            = local.probe_name
  port            = 80
  protocol        = "Tcp"
  depends_on = [
    azurerm_lb.appbalancer
  ]
}

resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.appbalancer.id
  name                           = local.lb_rule_name
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ip"
  probe_id                       = azurerm_lb_probe.probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.pool_address.id]
  depends_on = [
    azurerm_lb.appbalancer
  ]
}
