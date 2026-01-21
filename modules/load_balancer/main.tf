# 1. Public IP for App Gateway (Standard SKU is Mandatory)
resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.prefix}-appgw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 2. Application Gateway Configuration
resource "azurerm_application_gateway" "main" {
  name                = "${var.prefix}-appgw"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-config"
    subnet_id = var.appgw_subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-config"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = "fe-vmss-backend-pool"
  }

  backend_http_settings {
    name                  = "http-setting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "frontend-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                        = "rule1"
    rule_type                   = "Basic"
    http_listener_name          = "listener"
    backend_address_pool_name   = "fe-vmss-backend-pool"
    backend_http_settings_name  = "http-setting"
    priority                    = 1
  }
}

# DNS A Record - Requires existing DNS zone, commented out for now
# resource "azurerm_dns_a_record" "dns" {
#   name                = "www"
#   zone_name           = var.dns_zone_name
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   target_resource_id  = azurerm_public_ip.appgw_pip.id
# }

# App Gateway Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "appgw_diag" {
  name                       = "${var.prefix}-appgw-diag"
  target_resource_id         = azurerm_application_gateway.main.id
  log_analytics_workspace_id = var.log_analytics_id

  # Security Logs (WAF aur Access)
  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  # Performance Metrics
  enabled_metric {
    category = "AllMetrics"
    
  }
}