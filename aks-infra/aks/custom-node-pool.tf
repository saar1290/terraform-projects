resource "random_string" "custom_node_pool_suffix" {
  count = var.custom_node_pool == true ? length(var.node_pools[*]) : 0

  length  = 2
  special = false
  numeric = true
  upper   = false
  lower   = false

  keepers = {
    vm_size              = lookup(var.node_pools[count.index], "vm_size")
    gpu_instance         = lookup(var.node_pools[count.index], "gpu_instance")
    os_type              = lookup(var.node_pools[count.index], "os_type")
    os_disk_type         = lookup(var.node_pools[count.index], "os_disk_type")
    os_disk_size_gb      = lookup(var.node_pools[count.index], "os_disk_size_gb")
    orchestrator_version = var.k8s_version
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "custom_node_pool" {
  count                   = var.custom_node_pool == true ? length(var.node_pools[*]) : 0
  name                    = "${lookup(var.node_pools[count.index], "name")}${random_string.custom_node_pool_suffix[count.index].result}"
  kubernetes_cluster_id   = azurerm_kubernetes_cluster.aks.id
  orchestrator_version    = var.k8s_version
  host_encryption_enabled = true
  vm_size                 = lookup(var.node_pools[count.index], "vm_size")
  node_count              = lookup(var.node_pools[count.index], "node_count")
  auto_scaling_enabled    = lookup(var.node_pools[count.index], "enable_auto_scaling")
  max_pods                = lookup(var.node_pools[count.index], "max_pods")
  max_count               = lookup(var.node_pools[count.index], "max_count")
  min_count               = lookup(var.node_pools[count.index], "min_count")
  gpu_instance            = lookup(var.node_pools[count.index], "gpu_instance")
  ultra_ssd_enabled       = lookup(var.node_pools[count.index], "ultra_ssd_enabled")
  os_disk_size_gb         = lookup(var.node_pools[count.index], "os_disk_size_gb")
  os_disk_type            = lookup(var.node_pools[count.index], "os_disk_type")
  os_type                 = lookup(var.node_pools[count.index], "os_type")
  os_sku                  = lookup(var.node_pools[count.index], "os_sku")
  node_taints             = lookup(var.node_pools[count.index], "node_taints")
  node_labels             = lookup(var.node_pools[count.index], "node_labels")
  pod_subnet_id           = var.pod_subnet_id
  vnet_subnet_id          = var.workerpool_subnet_id
  fips_enabled            = lookup(var.node_pools[count.index], "fips_enabled")
  zones                   = lookup(var.node_pools[count.index], "zones")

  tags = var.tags

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_kubernetes_cluster_node_pool.worker
  ]

  lifecycle {
    create_before_destroy = true
  }
}