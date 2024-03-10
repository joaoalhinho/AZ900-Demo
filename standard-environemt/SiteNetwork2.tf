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
  name     = "${var.prefix}Site2-vnet"
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

#creating NSG
# Create Network Security Group and rule
resource "azurerm_network_security_group" "Site2BSG" {
  name                = "${var.prefix}Site2-nsg"
  location            = azurerm_resource_group.Site2Net.location
  resource_group_name = azurerm_resource_group.Site2Net.name

  security_rule {
    name                       = "SSH"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "Site2BSG" {
  subnet_id                 = azurerm_subnet.Site2SubSer.id
  network_security_group_id = azurerm_network_security_group.Site2BSG.id
}
