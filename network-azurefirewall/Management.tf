#providers in provider.tf file
#variables in variables.tf file

resource "azurerm_resource_group" "Management" {
  name     = "${var.prefix}Management-rg"
  location = var.LocationCoreNet
}

#log analytics
resource "azurerm_log_analytics_workspace" "CentralLogging" {
  name                = "${var.prefix}Log-log"
  location            = azurerm_resource_group.Management.location
  resource_group_name = azurerm_resource_group.Management.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

#ip groups
resource "azurerm_ip_group" "CoreNetwork" {
  name                = "${var.prefix}CoreNetwork-ipg"
  location            = azurerm_resource_group.Management.location
  resource_group_name = azurerm_resource_group.Management.name

  cidrs = azurerm_virtual_network.CoreNetwork.address_space
}

resource "azurerm_ip_group" "AllSites" {
  name                = "${var.prefix}AllSites-ipg"
  location            = azurerm_resource_group.Management.location
  resource_group_name = azurerm_resource_group.Management.name

  cidrs = ["10.10.0.0/21", "10.0.0.0/21", "172.16.0.0/21"]
}

resource "azurerm_ip_group" "ServerSubnets" {
  name                = "${var.prefix}ServerSubnets-ipg"
  location            = azurerm_resource_group.Management.location
  resource_group_name = azurerm_resource_group.Management.name

  cidrs = ["10.10.0.0/24", "172.16.0.0/24", "10.0.0.0/24"]
}

