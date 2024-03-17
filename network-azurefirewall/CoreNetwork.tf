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
  name                = "${var.prefix}CoreNetwork-vnet"
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

#deploy routes to Azure Firewall
resource "azurerm_route_table" "CoreNetworkRoute" {
  name                          = "${var.prefix}CoreNetwork-route"
  location                      = azurerm_resource_group.CoreNetwork.location
  resource_group_name           = azurerm_resource_group.CoreNetwork.name
  disable_bgp_route_propagation = false

  route {
    name                   = "FW-DefaultRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.AzureFW_IP
  }
}

resource "azurerm_subnet_route_table_association" "CoreNetwork-FW" {
  subnet_id      = azurerm_subnet.CoreNetwork.id
  route_table_id = azurerm_route_table.CoreNetworkRoute.id
}


###### Network peering
resource "azurerm_virtual_network_peering" "CoreNetTOSite1" {
  name                         = "CoreNetTOSite1"
  resource_group_name          = azurerm_resource_group.CoreNetwork.name
  virtual_network_name         = azurerm_virtual_network.CoreNetwork.name
  remote_virtual_network_id    = azurerm_virtual_network.Site1Net.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "CoreNetTOSite2" {
  name                         = "CoreNetTOSite2"
  resource_group_name          = azurerm_resource_group.CoreNetwork.name
  virtual_network_name         = azurerm_virtual_network.CoreNetwork.name
  remote_virtual_network_id    = azurerm_virtual_network.Site2Net.id
  allow_virtual_network_access = true
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
  registration_enabled  = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "az900Site2" {
  name                  = "${var.prefix}.com_Site2"
  resource_group_name   = azurerm_resource_group.CoreNetwork.name
  private_dns_zone_name = azurerm_private_dns_zone.az900.name
  virtual_network_id    = azurerm_virtual_network.Site2Net.id
  registration_enabled  = true
}