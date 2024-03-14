output "info-netgroupmeber" {
  description = "valPlease remove all network group member and re-add them again manallyue"
  value = "Please remove all network group member and re-add them again manally"
}

output "info-VPN" {
  description = "valPlease remove all network group member and re-add them again manallyue"
  value = "Please remove all network group member and re-add them again manally"
}

output "Routes-add1" {
  value = azurerm_virtual_network.Site1Net.address_space
}

output "Routes-add2" {
  value = azurerm_virtual_network.Site2Net.address_space
}


