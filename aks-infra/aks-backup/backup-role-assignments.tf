resource "azurerm_role_assignment" "aks_backup_extension_and_storage_account_permission" {
  scope                = azurerm_storage_account.aks_backup.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_kubernetes_cluster_extension.aks_backup.aks_assigned_identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_backup_vault_msi_read_on_cluster" {
  scope                = var.cluster_id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.aks_backup.identity[0].principal_id

  depends_on = [
    azurerm_data_protection_backup_vault.aks_backup
  ]
}

resource "azurerm_role_assignment" "aks_backup_vault_msi_read_on_snap_rg" {
  scope                = azurerm_resource_group.aks_backup_snapshot.id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.aks_backup.identity[0].principal_id

  depends_on = [
    azurerm_resource_group.aks_backup_snapshot,
    azurerm_data_protection_backup_vault.aks_backup
  ]
}

resource "azurerm_role_assignment" "aks_backup_vault_msi_snapshot_contributor_on_snap_rg" {
  scope                = azurerm_resource_group.aks_backup_snapshot.id
  role_definition_name = "Disk Snapshot Contributor"
  principal_id         = azurerm_data_protection_backup_vault.aks_backup.identity[0].principal_id

  depends_on = [
    azurerm_resource_group.aks_backup_snapshot,
    azurerm_data_protection_backup_vault.aks_backup
  ]
}

resource "azurerm_role_assignment" "aks_backup_vault_data_operator_on_snap_rg" {
  scope                = azurerm_resource_group.aks_backup_snapshot.id
  role_definition_name = "Data Operator for Managed Disks"
  principal_id         = azurerm_data_protection_backup_vault.aks_backup.identity[0].principal_id

  depends_on = [
    azurerm_resource_group.aks_backup_snapshot,
    azurerm_data_protection_backup_vault.aks_backup
  ]
}

resource "azurerm_role_assignment" "aks_backup_vault_data_contributor_on_storage" {
  scope                = azurerm_storage_account.aks_backup.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_protection_backup_vault.aks_backup.identity[0].principal_id

  depends_on = [
    azurerm_storage_container.aks_backup,
    azurerm_data_protection_backup_vault.aks_backup
  ]
}

resource "azurerm_role_assignment" "aks_backup_cluster_msi_contributor_on_snap_rg" {
  scope                = azurerm_resource_group.aks_backup_snapshot.id
  role_definition_name = "Contributor"
  principal_id         = var.principal_id

  depends_on = [
    azurerm_resource_group.aks_backup_snapshot
  ]
}