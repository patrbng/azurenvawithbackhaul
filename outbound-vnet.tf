locals {
  prefix-outbound         = "outbound"
  outbound-location       = "CentralUS"
  outbound-resource-group = "outbound-vnet-rg"
}

resource "azurerm_resource_group" "outbound-vnet-rg" {
  name     = local.outbound-resource-group
  location = local.outbound-location
}

resource "azurerm_virtual_network" "outbound-vnet" {
  name                = "${local.prefix-outbound}-vnet"
  location            = azurerm_resource_group.outbound-vnet-rg.location
  resource_group_name = azurerm_resource_group.outbound-vnet-rg.name
  address_space       = ["10.3.0.0/16"]

  tags = {
    environment = "outbound-spoke"
  }
}

resource "azurerm_subnet" "outbound-mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.outbound-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.outbound-vnet.name
  address_prefix       = "10.3.0.64/27"
}

resource "azurerm_subnet" "outbound-dmz" {
  name                 = "dmz"
  resource_group_name  = azurerm_resource_group.outbound-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.outbound-vnet.name
  address_prefix       = "10.3.0.32/27"
}

resource "azurerm_network_interface" "outbound-nic" {
  name                 = "${local.prefix-outbound}-nic"
  location             = azurerm_resource_group.outbound-vnet-rg.location
  resource_group_name  = azurerm_resource_group.outbound-vnet-rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = local.prefix-outbound
    subnet_id                     = azurerm_subnet.outbound-mgmt.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = local.prefix-outbound
  }
}

#Virtual Machine
resource "azurerm_virtual_machine" "outbound-vm" {
  name                  = "${local.prefix-outbound}-vm"
  location              = azurerm_resource_group.outbound-vnet-rg.location
  resource_group_name   = azurerm_resource_group.outbound-vnet-rg.name
  network_interface_ids = [azurerm_network_interface.outbound-nic.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.prefix-outbound}-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = local.prefix-outbound
  }
}