output "law_id" {
  value = azurerm_log_analytics_workspace.law.id
}

output "storage_primary_endpoint" {
  value = azurerm_storage_account.sa.primary_blob_endpoint
}