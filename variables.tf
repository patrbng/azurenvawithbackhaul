variable "location" {
  description = "Location of the network"
  default     = "centralus"
}

variable "username" {
  description = "Username for Virtual Machines"
  default     = "********"
}

variable "password" {
  description = "Password for Virtual Machines"
  default     = "***********"
}

variable "vmsize" {
  description = "Size of the VMs"
  default     = "Standard_DS1_v2"
}