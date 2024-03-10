#providers in provider.tf file
#variables in variables.tf file

#creating resource group
resource "azurerm_resource_group" "Servers" {
  name     = "${var.prefix}Servers-rg"
  location = var.LocationSite1
}

################################  Site 1   ################################
# Create public IPs
resource "azurerm_public_ip" "Site1Server" {
  name                = "${var.prefix}Site1Server-pip"
  location            = azurerm_resource_group.Site1Net.location
  resource_group_name = azurerm_resource_group.Servers.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prefix}1ite1server"
}

#creating network interface
resource "azurerm_network_interface" "Site1Server" {
  name                = "${var.prefix}Site1Server-nic"
  location            = azurerm_resource_group.Site1Net.location
  resource_group_name = azurerm_resource_group.Servers.name


  ip_configuration {
    name                          = "${var.prefix}Site1Server-ipc"
    subnet_id                     = azurerm_subnet.Site1SubSer.id
    private_ip_address_allocation = "dynamic"
    private_ip_address_version    = "IPv4"
    public_ip_address_id          = azurerm_public_ip.Site1Server.id
  }
}

resource "azurerm_network_interface_security_group_association" "Site1Server" {
  network_interface_id      = azurerm_network_interface.Site1Server.id
  network_security_group_id = azurerm_network_security_group.Site1BSG.id
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
# Create public IPs
resource "azurerm_public_ip" "Site2Server" {
  name                = "${var.prefix}Site2Server-pip"
  location            = azurerm_resource_group.Site2Net.location
  resource_group_name = azurerm_resource_group.Servers.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prefix}site2server"
}

#creating network interface
resource "azurerm_network_interface" "Site2Server" {
  name                = "${var.prefix}Site2Server-nic"
  location            = azurerm_resource_group.Site2Net.location
  resource_group_name = azurerm_resource_group.Servers.name


  ip_configuration {
    name                          = "${var.prefix}Site2Server-ipc"
    subnet_id                     = azurerm_subnet.Site2SubSer.id
    private_ip_address_allocation = "dynamic"
    private_ip_address_version    = "IPv4"
    public_ip_address_id          = azurerm_public_ip.Site2Server.id
  }
}

resource "azurerm_network_interface_security_group_association" "Site2Server" {
  network_interface_id      = azurerm_network_interface.Site2Server.id
  network_security_group_id = azurerm_network_security_group.Site2BSG.id
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

/*setting autoshutown (optional)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "Site2Server" {
  virtual_machine_id = azurerm_linux_virtual_machine.Site2Server.id
  location           = azurerm_resource_group.Site2Net.location
  enabled            = true

  daily_recurrence_time = "1800"
  timezone              = "W. Europe Standard Time"

  notification_settings {
    enabled = false
  }
}
*/
