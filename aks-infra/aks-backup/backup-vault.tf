resource "azurerm_data_protection_backup_vault" "aks_backup" {
  name                = "${var.backup_name}-vault"
  resource_group_name = var.rg
  location            = var.location
  datastore_type      = "VaultStore"
  redundancy          = "ZoneRedundant"
  soft_delete         = "Off"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  depends_on = [
    azurerm_resource_group.aks_backup_snapshot
  ]
}

resource "azurerm_kubernetes_cluster_trusted_access_role_binding" "aks_cluster_trusted_access_vault" {
  kubernetes_cluster_id = var.cluster_id
  name                  = azurerm_data_protection_backup_vault.aks_backup.name
  roles                 = ["Microsoft.DataProtection/backupVaults/backup-operator"]
  source_resource_id    = azurerm_data_protection_backup_vault.aks_backup.id
}