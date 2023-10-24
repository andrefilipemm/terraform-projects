module "resource-group-module" {
  source              = "./modules/resource-group"
  resource_group_name = "project-one-resource-grp"
  location            = "West Europe"
}

module "networking-module" {
  source                        = "./modules/networking"
  resource_group_name           = module.resource-group-module.resource_group_name
  location                      = module.resource-group-module.resource_group_location
  virtual_network_name          = "network"
  virtual_network_address_space = "10.0.0.0/16"
  subnet_names                  = ["subnet-1", "subnet-2"]
  bastion_required              = true
  network_security_group_names = {
    "nsg-1" = "subnet-1"
    "nsg-2" = "subnet-2"
  }
  network_security_group_rules = [
    { # Allow SSH access
      id                          = 1
      priority                    = "100"
      network_security_group_name = "nsg-1"
      destination_port_range      = "22"
      access                      = "Allow"
      protocol                    = "Tcp"
    },
    { # Allow RDP access
      id                          = 2
      priority                    = "200"
      network_security_group_name = "nsg-2"
      destination_port_range      = "3389"
      access                      = "Allow"
      protocol                    = "RDP"
    }
  ]
}