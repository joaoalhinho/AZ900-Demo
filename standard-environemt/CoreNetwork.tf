#providers in provider.tf file
#variables in variables.tf file

#creating resource group
resource "azurerm_resource_group" "CoreNetwork" {
  name     = "${var.prefix}CoreNetwork-rg"
  location = var.LocationCoreNet
}

################################  networking   ################################

#creating virtual network 
resource "azurerm_virtual_network" "CoreNetwork" {
  name     = "${var.prefix}CoreNetwork-vnet"
  address_space       = ["10.10.0.0/21"]
  location            = azurerm_resource_group.CoreNetwork.location
  resource_group_name = azurerm_resource_group.CoreNetwork.name
}

#creating subnet 
resource "azurerm_subnet" "CoreNetwork" {
  name                 = "${var.prefix}CoreNetwork-sub"
  resource_group_name  = azurerm_resource_group.CoreNetwork.name
  virtual_network_name = azurerm_virtual_network.CoreNetwork.name
  address_prefixes     = ["10.10.0.0/24"]
}

################################  dns zone   ################################
resource "azurerm_private_dns_zone" "az900" {
  name                = "az900.com"
  resource_group_name = azurerm_resource_group.CoreNetwork.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "az900Site1" {
  name                  = "${var.prefix}.com_Site1"
  resource_group_name   = azurerm_resource_group.CoreNetwork.name
  private_dns_zone_name = azurerm_private_dns_zone.az900.name
  virtual_network_id    = azurerm_virtual_network.Site1Net.id
  registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "az900Site2" {
  name                  = "${var.prefix}.com_Site2"
  resource_group_name   = azurerm_resource_group.CoreNetwork.name
  private_dns_zone_name = azurerm_private_dns_zone.az900.name
  virtual_network_id    = azurerm_virtual_network.Site2Net.id
  registration_enabled = true
}