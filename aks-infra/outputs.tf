output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "aks_cluster_fqdn" {
  value = module.aks.cluster_fqdn
}

output "aks_kubernetes_version" {
  value = module.aks.kubernetes_version
}

output "loadBalancerIP" {
  value = module.ingress-controller.loadBalancerIP
}