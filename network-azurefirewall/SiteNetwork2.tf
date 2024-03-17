#providers in provider.tf file
#variables in variables.tf file

#creating resource group
resource "azurerm_resource_group" "Site2Net" {
  name     = "${var.prefix}Site2Network-rg"
  location = var.LocationSite2
}

################################  networking   ################################

#creating virtual network 
resource "azurerm_virtual_network" "Site2Net" {
  name                = "${var.prefix}Site2-vnet"
  address_space       = ["172.16.0.0/21"]
  location            = azurerm_resource_group.Site2Net.location
  resource_group_name = azurerm_resource_group.Site2Net.name
}

#creating subnet 
resource "azurerm_subnet" "Site2SubSer" {
  name                 = "${var.prefix}Site2Server-sub"
  resource_group_name  = azurerm_resource_group.Site2Net.name
  virtual_network_name = azurerm_virtual_network.Site2Net.name
  address_prefixes     = ["172.16.0.0/24"]
}

resource "azurerm_virtual_network_peering" "Site2TOCoreNet" {
  name                      = "Site2TOCoreNet"
  resource_group_name       = azurerm_resource_group.Site2Net.name
  virtual_network_name      = azurerm_virtual_network.Site2Net.name
  remote_virtual_network_id = azurerm_virtual_network.CoreNetwork.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}

#deploy routes to Azure Firewall
resource "azurerm_route_table" "Site2Route" {
  name                          = "${var.prefix}Site2-route"
  location                      = azurerm_resource_group.Site2Net.location
  resource_group_name           = azurerm_resource_group.Site2Net.name
  disable_bgp_route_propagation = false

  route {
    name                   = "FW-DefaultRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.AzureFW_IP
  }
}

resource "azurerm_subnet_route_table_association" "Site2-FW" {
  subnet_id      = azurerm_subnet.Site2SubSer.id
  route_table_id = azurerm_route_table.Site2Route.id
}