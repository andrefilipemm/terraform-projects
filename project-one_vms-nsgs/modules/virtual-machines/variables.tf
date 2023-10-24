variable "resource_group_name" {
  type        = string
  description = "This defines the resource group name"
}

variable "location" {
  type        = string
  description = "This defines the location of the virtual network"
}

variable "virtual_network_name" {
  type        = string
  description = "This defines the virtual network name"
}

variable "virtual_network_address_space" {
  type        = string
  description = "This defines the virtual network's address space"
}

variable "subnet_names" {
  type        = list(string)
  description = "This defines a list containing the names of the subnets within the virtual network"
}

variable "bastion_required" {
  type        = bool
  description = "This defines whether the bastion service is required"
  default     = false
}

variable "network_security_group_names" {
  type        = map(string)
  description = "This defines a map of strings that maps names of NSGs to corresponding subnets"
}

variable "network_security_group_rules" {
  type        = list(any) # a list of map based objects
  description = "This defines a list containing the network security rules to allow SSH/RDP access for administrative purposes"
}

variable "number_vms" {
  type = number
  description = "This defines the number of virtual machines to be deployed"
  default = 2
}

variable "vm_size" {
  type = string
  description = "This defines the size of the virtual machine"
}