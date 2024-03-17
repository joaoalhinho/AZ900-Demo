#providers in provider.tf file
#variables in variables.tf file

################################  Azure Firewall  ################################
#creating public ip for Azure Firewall
resource "azurerm_public_ip" "CoreNetworkFW" {
  name                = "${var.prefix}CoreNetworkFW-pip"
  location            = azurerm_resource_group.CoreNetwork.location
  resource_group_name = azurerm_resource_group.CoreNetwork.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#creating public ip for Azure Firewall mgt
resource "azurerm_public_ip" "CoreNetworkFWMgmt" {
  name                = "${var.prefix}CoreNetworkFWMgmt-pip"
  location            = azurerm_resource_group.CoreNetwork.location
  resource_group_name = azurerm_resource_group.CoreNetwork.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#creating subnets for Azure Firewall
resource "azurerm_subnet" "CoreNetworkAzureFW" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.CoreNetwork.name
  virtual_network_name = azurerm_virtual_network.CoreNetwork.name
  address_prefixes     = ["10.10.1.0/26"]
}

resource "azurerm_subnet" "CoreNetworkAzureFWMgmt" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = azurerm_resource_group.CoreNetwork.name
  virtual_network_name = azurerm_virtual_network.CoreNetwork.name
  address_prefixes     = ["10.10.1.128/26"]
}

#creating firewall policy
resource "azurerm_firewall_policy" "CoreNetwork" {
  name                = "${var.prefix}CoreNetworkFW-fwpol"
  resource_group_name = azurerm_resource_group.CoreNetwork.name
  location            = azurerm_resource_group.CoreNetwork.location
  sku                 = "Basic"

}

#creatingAzure Firewall
resource "azurerm_firewall" "CoreNetworkFW" {
  name                = "${var.prefix}CoreNetwork-fw"
  location            = azurerm_resource_group.CoreNetwork.location
  resource_group_name = azurerm_resource_group.CoreNetwork.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Basic"
  firewall_policy_id  = azurerm_firewall_policy.CoreNetwork.id

  ip_configuration {
    name                 = "${var.prefix}CoreNetworkFW-ipc01"
    subnet_id            = azurerm_subnet.CoreNetworkAzureFW.id
    public_ip_address_id = azurerm_public_ip.CoreNetworkFW.id
  }
  management_ip_configuration {
    name                 = "${var.prefix}CoreNetworkFW-ipc02"
    subnet_id            = azurerm_subnet.CoreNetworkAzureFWMgmt.id
    public_ip_address_id = azurerm_public_ip.CoreNetworkFWMgmt.id
  }
}

#Firewall logging
resource "azurerm_monitor_diagnostic_setting" "FWLog" {
  name                       = "AuzureFirewallLogging"
  target_resource_id         = azurerm_firewall.CoreNetworkFW.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.CentralLogging.id

  enabled_log {
    category = "AZFWNetworkRule"
  }
  enabled_log {
    category = "AZFWApplicationRule"
  }
  enabled_log {
    category = "AZFWNatRule"
  }
  enabled_log {
    category = "AZFWDnsQuery"
  }
  enabled_log {
    category = "AZFWFqdnResolveFailure"
  }
  enabled_log {
    category = "AZFWApplicationRuleAggregation"
  }
  enabled_log {
    category = "AZFWNetworkRuleAggregation"
  }
  enabled_log {
    category = "AZFWNatRuleAggregation"
  }
    enabled_log {
    category = "AZFWFlowTrace"
  }


  metric {
    category = "AllMetrics"
  }
}

#defining network rules
resource "azurerm_firewall_policy_rule_collection_group" "NetManagement" {
  name               = "DefaultManagementAccess"
  firewall_policy_id = azurerm_firewall_policy.CoreNetwork.id
  priority           = 300
  network_rule_collection {
    name     = "DefaultManagementAccess"
    action   = "Allow"
    priority = 500
    rule {
      name                  = "AllowICMP"
      protocols             = ["ICMP"]
      source_ip_groups      = [azurerm_ip_group.AllSites.id]
      destination_ip_groups = [azurerm_ip_group.AllSites.id]
      destination_ports     = ["*"]
    }
    rule {
      name                  = "AllowDNSOut"
      protocols             = ["UDP"]
      source_ip_groups      = [azurerm_ip_group.AllSites.id]
      destination_ip_groups = [azurerm_ip_group.AllSites.id]
      destination_ports     = ["53"]
    }
    rule {
      name                  = "AllowSSH"
      protocols             = ["TCP"]
      source_ip_groups      = [azurerm_ip_group.ServerSubnets.id]
      destination_ip_groups = [azurerm_ip_group.ServerSubnets.id]
      destination_ports     = ["22"]
    }
  }
}


#defining application rules 
resource "azurerm_firewall_policy_rule_collection_group" "AppWeb" {
  name               = "DefaultWebOutbound"
  firewall_policy_id = azurerm_firewall_policy.CoreNetwork.id
  priority           = 500
  application_rule_collection {
    name     = "AllowWebOutbound"
    action   = "Allow"
    priority = 500
    rule {
      name = "AllowWebOutbound"

      description = "AllowWebOutbound"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*"]
    }
  }
}

#defining DNAT roules for remote management
resource "azurerm_firewall_policy_rule_collection_group" "DNAT" {
  name               = "DNATManagementAccess"
  firewall_policy_id = azurerm_firewall_policy.CoreNetwork.id
  priority           = 300
  nat_rule_collection {
    name     = "SSHInbound"
    priority = 300
    action   = "Dnat"
    rule {
      name                = "SSHInbound_CoreNetServer"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_address = azurerm_public_ip.CoreNetworkFW.ip_address
      destination_ports   = ["8022"]
      translated_address  = azurerm_linux_virtual_machine.CorenetServer.private_ip_address
      translated_port     = "22"
    }
    rule {
      name                = "SSHInbound_Site1Server"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_address = azurerm_public_ip.CoreNetworkFW.ip_address
      destination_ports   = ["8122"]
      translated_address  = azurerm_linux_virtual_machine.Site1Server.private_ip_address
      translated_port     = "22"
    }
    rule {
      name                = "SSHInbound_Site2Server"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_address = azurerm_public_ip.CoreNetworkFW.ip_address
      destination_ports   = ["8222"]
      translated_address  = azurerm_linux_virtual_machine.Site2Server.private_ip_address
      translated_port     = "22"
    }
  }
}
