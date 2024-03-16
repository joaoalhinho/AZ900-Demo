#providers in provider.tf file
#variables in variables.tf file

################################  networking Site 3   ################################
#creating resource group
resource "azurerm_resource_group" "Site3Net" {
  name     = "${var.prefix}Site3Network-rg"
  location = var.LocationSite3
}

#creating virtual network 
resource "azurerm_virtual_network" "Site3Net" {
  name     = "${var.prefix}Site3-vnet"
  address_space       = ["172.16.200.0/22"]
  location            = azurerm_resource_group.Site3Net.location
  resource_group_name = azurerm_resource_group.Site3Net.name
}

#creating subnet 
resource "azurerm_subnet" "Site3SubSer" {
  name                 = "${var.prefix}Site3Server-sub"
  resource_group_name  = azurerm_resource_group.Site3Net.name
  virtual_network_name = azurerm_virtual_network.Site3Net.name
  address_prefixes     = ["172.16.200.0/24"]
}

#creating NSG
# Create Network Security Group and rule
resource "azurerm_network_security_group" "Site3BSG" {
  name                = "${var.prefix}Site3-nsg"
  location            = azurerm_resource_group.Site3Net.location
  resource_group_name = azurerm_resource_group.Site3Net.name

  security_rule {
    name                       = "AllowVPNInboundICMP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "192.168.254.0/24"
    destination_address_prefix = "*"
  }

   security_rule {
    name                       = "AllowVPNInboundSSH"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "192.168.254.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "BlockVPNInboundTraffic"
    priority                   = 3000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "192.168.254.0/24"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "Site3BSG" {
  subnet_id                 = azurerm_subnet.Site3SubSer.id
  network_security_group_id = azurerm_network_security_group.Site3BSG.id
}