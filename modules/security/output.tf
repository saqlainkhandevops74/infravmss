output "public_key" {
  value = tls_private_key.vm_ssh_key.public_key_openssh
}

output "kv_id" {
  value = azurerm_key_vault.kv.id
}