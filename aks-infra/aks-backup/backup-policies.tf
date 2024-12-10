resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "aks_backup_hourly" {
  name                            = "${var.backup_name}-hourly"
  resource_group_name             = azurerm_data_protection_backup_vault.aks_backup.resource_group_name
  vault_name                      = azurerm_data_protection_backup_vault.aks_backup.name
  time_zone                       = "Israel Standard Time"
  backup_repeating_time_intervals = var.backup_repeating_time_interval

  default_retention_rule {
    life_cycle {
      duration        = "P${var.backup_retention_days}D"
      data_store_type = "OperationalStore"
    }
  }

  depends_on = [
    azurerm_kubernetes_cluster_trusted_access_role_binding.aks_cluster_trusted_access_vault
  ]
}