#providers in provider.tf file
#variables in variables.tf file

#creating resource group
resource "azurerm_resource_group" "Site1Net" {
  name     = "${var.prefix}Site1Network-rg"
  location = var.LocationSite1
}

################################  networking   ################################

#creating virtual network 
resource "azurerm_virtual_network" "Site1Net" {
  name     = "${var.prefix}Site1-vnet"
  address_space       = ["10.0.0.0/21"]
  location            = azurerm_resource_group.Site1Net.location
  resource_group_name = azurerm_resource_group.Site1Net.name
}

#creating subnet 
resource "azurerm_subnet" "Site1SubSer" {
  name                 = "${var.prefix}Site1Server-sub"
  resource_group_name  = azurerm_resource_group.Site1Net.name
  virtual_network_name = azurerm_virtual_network.Site1Net.name
  address_prefixes     = ["10.0.0.0/24"]
}

###### Network peering
resource "azurerm_virtual_network_peering" "Site1TOCoreNet" {
  name                      = "Site1TOCoreNet"
  resource_group_name       = azurerm_resource_group.Site1Net.name
  virtual_network_name      = azurerm_virtual_network.Site1Net.name
  remote_virtual_network_id = azurerm_virtual_network.CoreNetwork.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}

#deploy routes to Azure Firewall
resource "azurerm_route_table" "Site1Route" {
  name                          = "${var.prefix}Site1-route"
  location                      = azurerm_resource_group.Site1Net.location
  resource_group_name           = azurerm_resource_group.Site1Net.name
  disable_bgp_route_propagation = false

  route {
    name           = "FW-DefaultRoute"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "${var.AzureFW_IP}"
  }
}

resource "azurerm_subnet_route_table_association" "Site1-FW" {
  subnet_id      = azurerm_subnet.Site1SubSer.id
  route_table_id = azurerm_route_table.Site1Route.id
}
