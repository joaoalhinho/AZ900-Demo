#providers in provider.tf file
#variables in variables.tf file

#creating resource group
resource "azurerm_resource_group" "WebApp" {
  name     = "${var.prefix}WebApp-rg"
  location = var.LocationSite1
}

#newrokting components 
resource "azurerm_public_ip" "WebApp" {
  name                = "${var.prefix}WebApp-pip"
  location            = azurerm_resource_group.WebApp.location
  resource_group_name = azurerm_resource_group.WebApp.name
  allocation_method   = "Static"
  domain_name_label   = "${var.prefix}webapp"
}

resource "azurerm_lb" "WebApp" {
  name                = "${var.prefix}WebApp-lb"
  location            = azurerm_resource_group.WebApp.location
  resource_group_name = azurerm_resource_group.WebApp.name

  frontend_ip_configuration {
    name                 = "ipconfig"
    public_ip_address_id = azurerm_public_ip.WebApp.id
  }
}

resource "azurerm_lb_backend_address_pool" "WebServer" {
  loadbalancer_id = azurerm_lb.WebApp.id
  name            = "FronEndWebServer"
}

resource "azurerm_lb_probe" "WebAppHTTP" {
  resource_group_name = azurerm_resource_group.WebApp.name
  loadbalancer_id     = azurerm_lb.WebApp.id
  name                = "ssh-running-probe"
  port                = 80
}

resource "azurerm_lb_rule" "WebApp" {
  resource_group_name            = azurerm_resource_group.WebApp.name
  loadbalancer_id                = azurerm_lb.WebApp.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.WebServer.id]
  frontend_ip_configuration_name = "ipconfig"
  probe_id                       = azurerm_lb_probe.WebAppHTTP.id
}

#creating VM scale set

resource "azurerm_virtual_machine_scale_set" "WebApp" {
  name                = "${var.prefix}WebApp-vm"
  location            = azurerm_resource_group.WebApp.location
  resource_group_name = azurerm_resource_group.WebApp.name

  # automatic rolling upgrade
  automatic_os_upgrade = true
  upgrade_policy_mode  = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  # required when using rolling upgrade policy
  health_probe_id = azurerm_lb_probe.WebAppHTTP.id

  sku {
    name     = "Standard_B2als_v2"
    tier     = "Standard"
    capacity = 3 #number of virtual machines
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name_prefix = "${var.prefix}WebApp"
    admin_username       = var.adminname
    admin_password       = var.adminpw
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_profile {
    name    = "WebServerCluster"
    primary = true

    ip_configuration {
      name                                   = "ipconfig"
      primary                                = true
      subnet_id                              = azurerm_subnet.Site1SubSer.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.WebServer.id]
    }
  }
}
