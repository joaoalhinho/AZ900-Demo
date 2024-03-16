#providers in provider.tf file
#variables in variables.tf file

#creating resource group
resource "azurerm_resource_group" "Servers" {
  name     = "${var.prefix}Servers-rg"
  location = var.LocationSite1
}

################################  Site 1   ################################
#creating network interface
resource "azurerm_network_interface" "Site1Server" {
  name                = "${var.prefix}Site1Server-nic"
  location            = azurerm_resource_group.Site1Net.location
  resource_group_name = azurerm_resource_group.Servers.name


  ip_configuration {
    name                          = "${var.prefix}Site1Server-ipc"
    subnet_id                     = azurerm_subnet.Site1SubSer.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
  }
}

######creating ubunu server site 1
resource "azurerm_linux_virtual_machine" "Site1Server" {
  name                = "${var.prefix}Site1Server-vm"
  resource_group_name = azurerm_resource_group.Servers.name
  location            = azurerm_resource_group.Site1Net.location
  size                = "Standard_B2als_v2"
  computer_name       = "${var.prefix}Site1Server"
  disable_password_authentication = false
  admin_username      = var.adminname
  admin_password      = var.adminpw
  patch_mode          = "AutomaticByPlatform"
  #custom_data    = base64encode(data.template_file.linux-vm-cloud-init.rendered)

  network_interface_ids = [
    azurerm_network_interface.Site1Server.id,
  ]

  os_disk {
    name                 = "${var.prefix}Site1Server-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

#setting autoshutown (optional)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "Site1Server" {
  virtual_machine_id = azurerm_linux_virtual_machine.Site1Server.id
  location           = azurerm_resource_group.Site1Net.location
  enabled            = true

  daily_recurrence_time = "1800"
  timezone              = "W. Europe Standard Time"

  notification_settings {
    enabled = false
  }
}


################################  Site 2   ################################
#creating network interface
resource "azurerm_network_interface" "Site2Server" {
  name                = "${var.prefix}Site2Server-nic"
  location            = azurerm_resource_group.Site2Net.location
  resource_group_name = azurerm_resource_group.Servers.name


  ip_configuration {
    name                          = "${var.prefix}Site2Server-ipc"
    subnet_id                     = azurerm_subnet.Site2SubSer.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
  }
}

######creating ubunu server site 1
resource "azurerm_linux_virtual_machine" "Site2Server" {
  name                = "${var.prefix}Site2Server-vm"
  resource_group_name = azurerm_resource_group.Servers.name
  location            = azurerm_resource_group.Site2Net.location
  size                = "Standard_B2als_v2"
  computer_name       = "${var.prefix}Site2Server"
  disable_password_authentication = false
  admin_username      = var.adminname
  admin_password      = var.adminpw
  patch_mode          = "AutomaticByPlatform"
  #custom_data    = base64encode(data.template_file.linux-vm-cloud-init.rendered)

  network_interface_ids = [
    azurerm_network_interface.Site2Server.id,
  ]

  os_disk {
    name                 = "${var.prefix}Site2Server-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

################################  Site 3   ################################
#creating network interface
resource "azurerm_network_interface" "Site3Server" {
  name                = "${var.prefix}Site3Server-nic"
  location            = azurerm_resource_group.Site3Net.location
  resource_group_name = azurerm_resource_group.Servers.name


  ip_configuration {
    name                          = "${var.prefix}Site3Server-ipc"
    subnet_id                     = azurerm_subnet.Site3SubSer.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
  }
}

######creating ubunu server site 1
resource "azurerm_linux_virtual_machine" "Site3Server" {
  name                = "${var.prefix}Site3Server-vm"
  resource_group_name = azurerm_resource_group.Servers.name
  location            = azurerm_resource_group.Site3Net.location
  size                = "Standard_B2als_v2"
  computer_name       = "${var.prefix}Site3Server"
  disable_password_authentication = false
  admin_username      = var.adminname
  admin_password      = var.adminpw
  patch_mode          = "AutomaticByPlatform"
  #custom_data    = base64encode(data.template_file.linux-vm-cloud-init.rendered)

  network_interface_ids = [
    azurerm_network_interface.Site3Server.id,
  ]

  os_disk {
    name                 = "${var.prefix}Site3Server-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

#setting autoshutown (optional)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "Site3Server" {
  virtual_machine_id = azurerm_linux_virtual_machine.Site3Server.id
  location           = azurerm_resource_group.Site3Net.location
  enabled            = true

  daily_recurrence_time = "1800"
  timezone              = "W. Europe Standard Time"

  notification_settings {
    enabled = false
  }
}