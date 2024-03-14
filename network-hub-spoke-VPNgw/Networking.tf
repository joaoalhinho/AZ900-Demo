#providers in provider.tf file
#variables in variables.tf file

#creating resource group
resource "azurerm_resource_group" "CoreNetwork" {
  name     = "${var.prefix}CoreNetwork-rg"
  location = var.LocationCoreNet
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

################################  networking Site 1   ################################
#creating resource group
resource "azurerm_resource_group" "Site1Net" {
  name     = "${var.prefix}Site1Network-rg"
  location = var.LocationSite1
}

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

resource "azurerm_subnet_network_security_group_association" "Site1BSG" {
  subnet_id                 = azurerm_subnet.Site1SubSer.id
  network_security_group_id = azurerm_network_security_group.Site1BSG.id
}


################################  networking Site 2   ################################
#creating resource group
resource "azurerm_resource_group" "Site2Net" {
  name     = "${var.prefix}Site2Network-rg"
  location = var.LocationSite2
}

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

resource "azurerm_subnet_network_security_group_association" "Site2BSG" {
  subnet_id                 = azurerm_subnet.Site2SubSer.id
  network_security_group_id = azurerm_network_security_group.Site2BSG.id
}

######## Hub and Spoke config
data "azurerm_subscription" "current" {
}

######## Netwrok Manager
resource "azurerm_network_manager" "CoreNetwork" {
  name                = "${var.prefix}CoreNetwork-netman"
  location            = azurerm_resource_group.CoreNetwork.location
  resource_group_name = azurerm_resource_group.CoreNetwork.name
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["Connectivity", "SecurityAdmin"]
}

######## Netwrok Manager - Networg Group 
resource "azurerm_network_manager_network_group" "CoreNetwork" {
  name               = "${var.prefix}CoreNetwork-netmangrp"
  network_manager_id = azurerm_network_manager.CoreNetwork.id
}

#### Network Group Members
resource "azurerm_network_manager_static_member" "Site1" {
  name                      = azurerm_virtual_network.Site1Net.name
  network_group_id          = azurerm_network_manager_network_group.CoreNetwork.id
  target_virtual_network_id = azurerm_virtual_network.Site1Net.id
  
}

resource "azurerm_network_manager_static_member" "Site2" {
  name                      = azurerm_virtual_network.Site2Net.name
  network_group_id          = azurerm_network_manager_network_group.CoreNetwork.id
  target_virtual_network_id = azurerm_virtual_network.Site2Net.id
}

#### connectivity configuration
resource "azurerm_network_manager_connectivity_configuration" "CoreNetwork" {
  name                  = "${var.prefix}CoreNetwork"
  network_manager_id    = azurerm_network_manager.CoreNetwork.id
  connectivity_topology = "HubAndSpoke"
  hub {
    resource_id = azurerm_virtual_network.CoreNetwork.id
    resource_type = "Microsoft.Network/virtualNetworks"
  }
  applies_to_group {
    group_connectivity = "DirectlyConnected"
    global_mesh_enabled = true
    use_hub_gateway = true
    network_group_id   = azurerm_network_manager_network_group.CoreNetwork.id
  }
}

# Commit deployment core network region
resource "azurerm_network_manager_deployment" "CoreNetwork" {
  network_manager_id = azurerm_network_manager.CoreNetwork.id
  location           = azurerm_resource_group.CoreNetwork.location
  scope_access       = "Connectivity"
  configuration_ids  = [azurerm_network_manager_connectivity_configuration.CoreNetwork.id]
}

# Commit deployment site1 network region
resource "azurerm_network_manager_deployment" "Site1" {
  network_manager_id = azurerm_network_manager.CoreNetwork.id
  location           = azurerm_resource_group.Site1Net.location
  scope_access       = "Connectivity"
  configuration_ids  = [azurerm_network_manager_connectivity_configuration.CoreNetwork.id]
}

# Commit deployment site2 network region
resource "azurerm_network_manager_deployment" "Site2" {
  network_manager_id = azurerm_network_manager.CoreNetwork.id
  location           = azurerm_resource_group.Site2Net.location
  scope_access       = "Connectivity"
  configuration_ids  = [azurerm_network_manager_connectivity_configuration.CoreNetwork.id]
}