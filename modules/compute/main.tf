resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.vmss_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  instances           = var.instance_count
  admin_username      = "azureuser"

  # Key Vault integration placeholder - password/key yahan se aayega
  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key # Ye hum Key Vault se lenge baad mein
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id
      
      # App Gateway ke Backend Pool se connect karne ke liye
      application_gateway_backend_address_pool_ids = var.app_gateway_backend_pool_ids
    }
  }
}

# Ye block VMSS ke logs ko LAW mein bhejta hai
resource "azurerm_monitor_diagnostic_setting" "vmss_diag" {
  name                       = "vmss-logs"
  target_resource_id         = azurerm_linux_virtual_machine_scale_set.vmss.id
  log_analytics_workspace_id = var.log_analytics_id

  # VMSS doesn't support enabled_log blocks, only metrics
  enabled_metric {
    category = "AllMetrics"
  }
}

