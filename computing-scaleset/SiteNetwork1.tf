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

#creating NSG
# Create Network Security Group and rule
resource "azurerm_network_security_group" "Site1BSG" {
  name                = "${var.prefix}Site1-nsg"
  location            = azurerm_resource_group.Site1Net.location
  resource_group_name = azurerm_resource_group.Site1Net.name

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

resource "azurerm_subnet_network_security_group_association" "Site1BSG" {
  subnet_id                 = azurerm_subnet.Site1SubSer.id
  network_security_group_id = azurerm_network_security_group.Site1BSG.id
}