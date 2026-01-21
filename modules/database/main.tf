# 1. Generate a strong random password
resource "random_password" "sql_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 2. Store SQL Password in Key Vault
resource "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-admin-password"
  value        = random_password.sql_admin_password.result
  key_vault_id = var.key_vault_id
}

# 3. Azure SQL Server
resource "azurerm_mssql_server" "server" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                      = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sql_admin_password.result
  minimum_tls_version          = "1.2"
}

# 4. SQL Database
resource "azurerm_mssql_database" "db" {
  name           = var.db_name
  server_id      = azurerm_mssql_server.server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "BasePrice"
  max_size_gb    = 2
  sku_name       = "Basic" # Dev ke liye sasta tier
}

# 5. VNET Rule: Only allow Backend Subnet to talk to SQL
resource "azurerm_mssql_virtual_network_rule" "vnet_rule" {
  name      = "sql-vnet-rule"
  server_id = azurerm_mssql_server.server.id
  subnet_id = var.backend_subnet_id
}

# SQL Database Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "sql_diag" {
  name                       = "${var.db_name}-diag"
  target_resource_id         = azurerm_mssql_database.db.id
  log_analytics_workspace_id = var.log_analytics_id

  # Auditing aur Errors ke liye logs
  enabled_log {
    category = "SQLSecurityAuditEvents"
  }

  enabled_log {
    category = "Errors"
  }

  enabled_log {
    category = "Blocks"
  }

  # Performance Metrics (DTU/CPU usage)
  enabled_metric {
    category = "AllMetrics"
    
  }
}