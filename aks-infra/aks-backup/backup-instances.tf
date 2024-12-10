resource "time_sleep" "permissions_propagation_timeout" {
  create_duration = "90s"

  depends_on = [
    azurerm_kubernetes_cluster_trusted_access_role_binding.aks_cluster_trusted_access_vault,
    azurerm_role_assignment.aks_backup_extension_and_storage_account_permission,
    azurerm_kubernetes_cluster_extension.aks_backup
  ]
}

resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "full-backup" {
  name                         = "aks-full-backup"
  location                     = azurerm_data_protection_backup_vault.aks_backup.location
  vault_id                     = azurerm_data_protection_backup_vault.aks_backup.id
  kubernetes_cluster_id        = var.cluster_id
  snapshot_resource_group_name = azurerm_resource_group.aks_backup_snapshot.name
  backup_policy_id             = azurerm_data_protection_backup_policy_kubernetes_cluster.aks_backup_hourly.id

  backup_datasource_parameters {
    cluster_scoped_resources_enabled = true
    volume_snapshot_enabled          = true
    excluded_resource_types          = []
    included_namespaces              = []
    included_resource_types          = []
    label_selectors                  = []
    excluded_namespaces = [
      "calico-system",
      "calico-apiserver",
      "tigera-operator",
      "kube-system",
      "kube-public",
      "kube-node-lease",
      "default",
      "gatekeeper-system",
      "ingress-basic",
      "dataprotection-microsoft"
    ]
  }

  depends_on = [
    time_sleep.permissions_propagation_timeout
  ]
}