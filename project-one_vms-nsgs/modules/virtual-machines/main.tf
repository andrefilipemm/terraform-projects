module "resource-group-module" {
  source              = ".././resource-group"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "networking-module" {
  source                        = ".././networking"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  virtual_network_name          = var.virtual_network_name
  virtual_network_address_space = var.virtual_network_address_space
  subnet_names                  = var.subnet_names
  bastion_required              = var.bastion_required
  network_security_group_names  = var.network_security_group_names
  network_security_group_rules  = var.network_security_group_rules
}

# Network Interface attached to each subnet (that exists within the virtual network)

resource "azurerm_network_interface" "network_interface" {
  count               = var.number_vms
  name                = "network-interface-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "network-interface-${count.index + 1}-ip"
    subnet_id                     = module.networking-module.subnets[count.index].id ###???
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    module.networking-module.virtualnetwork
  ]
}

# Virtual Machines

resource "azurerm_virtual_machine" "vm" {
  count                 = var.number_vms
  name                  = "vm-${count.index + 1}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.network_interface[count.index].id]
  vm_size               = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
