resource "azurerm_storage_account" "aks_backup" {
  name                             = replace(var.backup_name, "-", "")
  resource_group_name              = var.rg
  location                         = var.location
  account_tier                     = "Standard"
  account_replication_type         = "ZRS"
  allow_nested_items_to_be_public  = false
  shared_access_key_enabled        = false
  cross_tenant_replication_enabled = true


  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules = [
      "45.15.54.0/24",
      "45.15.52.0/24",
      "91.235.34.0/23"
    ]
    virtual_network_subnet_ids = [
      var.pod_subnet_id
    ]
  }

  tags = var.tags

  depends_on = [
    azurerm_data_protection_backup_vault.aks_backup
  ]
}

resource "azurerm_storage_container" "aks_backup" {
  name                  = "aks-backups"
  storage_account_name  = azurerm_storage_account.aks_backup.name
  container_access_type = "private"

  depends_on = [
    azurerm_storage_account.aks_backup
  ]
}