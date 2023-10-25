variable "resource_group_name" {
  type        = string
  description = "This defines the name of the resource group"
}

variable "location" {
  type        = string
  description = "This defines the location of the resource group"
}

variable "virtual_network_name" {
  type        = string
  description = "This defines the virtual network name"
}

variable "address_space" {
  type        = string
  description = "This defines the virtual network's address space"
}

variable "network_security_group_rules" {
  type        = list(any) # a list of map based objects
  description = "This defines a list containing the network security rules to allow SSH/RDP access for administrative purposes"
}
