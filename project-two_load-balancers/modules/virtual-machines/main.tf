module "resource-group-module" {
  source              = ".././resource-group"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "networking-module" {
  source                       = "./modules/networking"
  resource_group_name          = module.rg-module.resource_group_name
  location                     = module.rg-module.resource_group_location
  virtual_network_name         = var.virtual_network_name
  address_space                = [var.address_space]
  network_security_group_rules = var.network_security_group_rules
}

resource "azurerm_network_interface" "appinterface" {
  count               = var.number_vms
  name                = "appinterface${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.networking.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    module.networking-module
  ]
}

resource "azurerm_availability_set" "appset" {
  count                        = var.availability_set_required ? 1 : 0
  name                         = "app-set"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
  depends_on = [
    module.resource-group-module
  ]
}

resource "azurerm_linux_virtual_machine" "linux-vm" {
  count               = var.number_vms
  name                = "vm-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = "adminuser"
  availability_set_id = var.availability_set_required ? azurerm_availability_set.appset.id : null
  network_interface_ids = [
    azurerm_network_interface.appinterface.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
