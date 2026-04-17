resource "azurerm_windows_virtual_machine" "this" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.this.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.windows_sku
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  patch_mode            = "AutomaticByPlatform"
  hotpatching_enabled   = var.hotpatching_enabled
  enable_automatic_updates = true
  timezone              = var.timezone

  tags = var.tags
}

resource "azurerm_network_interface" "this" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

# Domain join extension
resource "azurerm_virtual_machine_extension" "domain_join" {
  count                = var.domain_name != "" ? 1 : 0
  name                 = "domain-join"
  virtual_machine_id   = azurerm_windows_virtual_machine.this.id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = jsonencode({
    Name    = var.domain_name
    OUPath  = var.domain_ou_path
    User    = var.domain_join_user
    Restart = true
    Options = 3
  })

  protected_settings = jsonencode({
    Password = var.domain_join_password
  })

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }
}

# Auto-shutdown
resource "azurerm_dev_test_global_vm_shutdown_schedule" "this" {
  count              = var.auto_shutdown_time != "" ? 1 : 0
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone              = var.timezone

  notification_settings { enabled = false }
}

# Antimalware extension
resource "azurerm_virtual_machine_extension" "antimalware" {
  name                 = "IaaSAntimalware"
  virtual_machine_id   = azurerm_windows_virtual_machine.this.id
  publisher            = "Microsoft.Azure.Security"
  type                 = "IaaSAntimalware"
  type_handler_version = "1.3"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    AntimalwareEnabled = true
    RealtimeProtectionEnabled = true
    ScheduledScanSettings = {
      isEnabled = true
      day       = 7
      time      = "120"
      scanType  = "Quick"
    }
  })
}
