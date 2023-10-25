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

