# 1. Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 2. Storage Account (for Diagnostics)
resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name # Global unique name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # Dev ke liye sasta
}