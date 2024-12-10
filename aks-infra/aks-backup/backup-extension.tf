resource "azurerm_kubernetes_cluster_extension" "aks_backup" {
  name              = "${var.backup_name}-ext"
  cluster_id        = var.cluster_id
  extension_type    = "Microsoft.DataProtection.Kubernetes"
  release_train     = "stable"
  release_namespace = "dataprotection-microsoft"
  configuration_settings = {
    "configuration.backupStorageLocation.bucket"                   = azurerm_storage_container.aks_backup.name
    "configuration.backupStorageLocation.config.resourceGroup"     = azurerm_storage_account.aks_backup.resource_group_name
    "configuration.backupStorageLocation.config.storageAccount"    = azurerm_storage_account.aks_backup.name
    "configuration.backupStorageLocation.config.subscriptionId"    = var.subscription_id
    "credentials.tenantId"                                         = var.tenant_id
    "configuration.backupStorageLocation.config.useAAD"            = true
    "configuration.backupStorageLocation.config.storageAccountURI" = "https://${azurerm_storage_account.aks_backup.name}.blob.core.windows.net/"
  }

  depends_on = [
    azurerm_kubernetes_cluster_trusted_access_role_binding.aks_cluster_trusted_access_vault,
    azurerm_data_protection_backup_policy_kubernetes_cluster.aks_backup_hourly
  ]
}