output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "cluster_fqdn" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}

output "cluster_portal_fqdn" {
  value = azurerm_kubernetes_cluster.aks.portal_fqdn
}

output "kubernetes_version" {
  value = azurerm_kubernetes_cluster.aks.kubernetes_version
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "principal_id" {
  value = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}