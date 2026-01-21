output "appgw_id" {
  value = azurerm_application_gateway.main.id
}

output "backend_pool_name" {
  value = "fe-vmss-backend-pool"
}

output "backend_pool_id" {
  value = "${azurerm_application_gateway.main.id}/backendAddressPools/fe-vmss-backend-pool"
}
