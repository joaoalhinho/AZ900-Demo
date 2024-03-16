#providers in provider.tf file
#variables in variables.tf file


################################  networking   ################################

resource "azurerm_subnet" "CoreNetworkGW" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.CoreNetwork.name
  virtual_network_name = azurerm_virtual_network.CoreNetwork.name
  address_prefixes     = ["10.10.7.0/24"]
}

resource "azurerm_subnet" "Site3NetGW" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.Site3Net.name
  virtual_network_name = azurerm_virtual_network.Site3Net.name
  address_prefixes     = ["172.16.201.0/27"]
}

resource "azurerm_public_ip" "CoreNetworkGW" {
  name                = "${var.prefix}CoreNetworkVPN-pip"
  location            = azurerm_resource_group.CoreNetwork.location
  resource_group_name = azurerm_resource_group.CoreNetwork.name

  allocation_method = "Dynamic"
}

resource "azurerm_public_ip" "Site3NetGW" {
  name                = "${var.prefix}Site3NetworkVPN-pip"
  location            = azurerm_resource_group.Site3Net.location
  resource_group_name = azurerm_resource_group.Site3Net.name

  allocation_method = "Dynamic"
}

################################  VPN Core Net  ################################
resource "azurerm_virtual_network_gateway" "CoreNetworkVPN" {
  name                = "${var.prefix}CoreNetworkVPN-vnetgw"
  location            = azurerm_resource_group.CoreNetwork.location
  resource_group_name = azurerm_resource_group.CoreNetwork.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.CoreNetworkGW.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.CoreNetworkGW.id
  }

  vpn_client_configuration {
    address_space = ["192.168.254.0/24"]

    root_certificate {
      name = "az900-VPNSRootCert"

      public_cert_data = <<EOF
MIIC9TCCAd2gAwIBAgIQH66JxBAhB59Bl4R39b0tPTANBgkqhkiG9w0BAQsFADAd
MRswGQYDVQQDDBJhejkwMC1WUE5TUm9vdENlcnQwHhcNMjQwMzEwMDk0MTAyWhcN
MzQwMzEwMDk1MTAwWjAdMRswGQYDVQQDDBJhejkwMC1WUE5TUm9vdENlcnQwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDt7/BG7XHWf0irA9L3gPvuRggA
88pu3xZaMPhip2/xwAibr1Kgi81x8Fvdw6yV1yyV43A213bKIJOjlCZpxyscyimm
frMkgEI17ZD2EwWUI1X29kco9sj9ARjBElf3oSjvJ79BLMQNOGfKO+RzZgsC5SNJ
S2zB7ntjttShZFvTLiuWgk8XM8zN4pMa24bs8L6E5iN2f7lxg8a9vVZu/zJkNUgh
YmS45DGkvW5PVqffYWmyMc09ayl49K1lOhC89CJCuJaEzURFvyyYAbKy0mD8RR54
4SRpJFqctdo/ZWcEZtA+BdQ5Dk7DUNG67ptHmrnZwGHF6I2nKVyEkf0wF+0NAgMB
AAGjMTAvMA4GA1UdDwEB/wQEAwICBDAdBgNVHQ4EFgQUfJw1emJN2i7vNfPzDYFV
mIF5sJ8wDQYJKoZIhvcNAQELBQADggEBAHnrStIm05G2MFvPyWnScNXKSOCap4tL
hVJXQ6+2H04ZiV6j+43V96WVlLzhLwPaQg3p8+2+28SRlPSpfgtxZn+ZF+oHXLmu
oMcvFhSYhMcSUtwRFFO1+A5ygokmCXTIzgje1fltuuSXzgpXwTskNp9jEq0PYRgJ
IEviPRo1b79r8pf35pc42bPbXNYILlsgUrQCaVRrR8644ft//xboJZo8NOp/6Fyj
KF0c/foSIkExiOtqWTnHs2y/a/rwup3XB4YcMHqTPuztv/czkchWb1QmUlZInIq7
pGsjlA/bdixbvuSq05IRErQ17IgXHVO8+xp/hWY5ZSypTBcRhZ4ggP0=
EOF
    }
  }
}

resource "azurerm_local_network_gateway" "CoreNetworkRemoteSite" {
  name                = "${var.prefix}CoreNetworkRemoteSite-vnetgw"
  location            = azurerm_resource_group.CoreNetwork.location
  resource_group_name = azurerm_resource_group.CoreNetwork.name
  gateway_address     = azurerm_public_ip.Site3NetGW.ip_address
  address_space       = azurerm_virtual_network.Site3Net.address_space
}

resource "azurerm_virtual_network_gateway_connection" "CoreNetworkRemoteSite" {
  name                = "${var.prefix}CoreNetworkRemoteSite-gwconn"
  location            = azurerm_resource_group.CoreNetwork.location
  resource_group_name = azurerm_resource_group.CoreNetwork.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.CoreNetworkVPN.id
  local_network_gateway_id   = azurerm_local_network_gateway.CoreNetworkRemoteSite.id
  enable_bgp                 = false
  shared_key                 = var.VPNPSK
}

################################  VPN Site 3  ################################
resource "azurerm_virtual_network_gateway" "Site3Net" {
  name                = "${var.prefix}Site3NetworkVPN-vnetgw"
  location            = azurerm_resource_group.Site3Net.location
  resource_group_name = azurerm_resource_group.Site3Net.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.Site3NetGW.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.Site3NetGW.id
  }
}

resource "azurerm_local_network_gateway" "Site3RemoteSite" {
  name                = "${var.prefix}Site3RemoteSite-localnetgw"
  location            = azurerm_resource_group.Site3Net.location
  resource_group_name = azurerm_resource_group.Site3Net.name
  gateway_address     = azurerm_public_ip.CoreNetworkGW.ip_address
  address_space       = ["10.10.0.0/21","172.16.0.0/21","10.10.0.0/21"]
}

resource "azurerm_virtual_network_gateway_connection" "Site3RemoteSite" {
  name                = "${var.prefix}Site3RemoteSite-gwconn"
  location            = azurerm_resource_group.Site3Net.location
  resource_group_name = azurerm_resource_group.Site3Net.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.Site3Net.id
  local_network_gateway_id   = azurerm_local_network_gateway.Site3RemoteSite.id
  shared_key                 = var.VPNPSK
  enable_bgp                 = false
}
