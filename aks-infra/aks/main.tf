resource "azurerm_kubernetes_cluster" "aks" {
  name                             = var.cluster_name
  location                         = var.location
  resource_group_name              = var.rg
  dns_prefix                       = "${var.dns_prefix}-DNS"
  http_application_routing_enabled = false
  azure_policy_enabled             = true
  local_account_disabled           = true
  sku_tier                         = "Standard"
  kubernetes_version               = var.k8s_version
  automatic_upgrade_channel        = var.upgrade_channel
  node_os_upgrade_channel          = "NodeImage"
  image_cleaner_enabled            = true
  image_cleaner_interval_hours     = var.image_cleaner_interval_hours
  cost_analysis_enabled            = true

  dynamic "maintenance_window" {
    for_each = {
      for key, value in var.maintenance[*] :
      key => value
      if lookup(value, "allowed_day") != null
    }

    content {
      allowed {
        day   = maintenance_window.value.allowed_day
        hours = maintenance_window.value.allowed_hours
      }
    }
  }

  dynamic "maintenance_window_auto_upgrade" {
    for_each = {
      for key, value in var.maintenance[*] :
      key => value
      if lookup(value, "start_time") != null
    }

    content {
      utc_offset  = maintenance_window_auto_upgrade.value.utc_offset
      frequency   = maintenance_window_auto_upgrade.value.frequency
      duration    = maintenance_window_auto_upgrade.value.duration
      interval    = maintenance_window_auto_upgrade.value.interval
      start_date  = timeadd(timestamp(), "24h")
      start_time  = maintenance_window_auto_upgrade.value.start_time
      day_of_week = maintenance_window_auto_upgrade.value.day_of_week
    }
  }

  dynamic "maintenance_window_node_os" {
    for_each = {
      for key, value in var.maintenance[*] :
      key => value
      if lookup(value, "start_time") != null
    }

    content {
      utc_offset  = maintenance_window_node_os.value.utc_offset
      frequency   = maintenance_window_node_os.value.frequency_node_os
      duration    = maintenance_window_node_os.value.duration
      interval    = maintenance_window_node_os.value.interval_node_os
      start_date  = timeadd(timestamp(), "24h")
      start_time  = maintenance_window_node_os.value.start_time
      day_of_week = maintenance_window_node_os.value.day_of_week_node_os
    }
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  default_node_pool {
    name                         = "infrapool"
    temporary_name_for_rotation  = "tmppool"
    only_critical_addons_enabled = true
    host_encryption_enabled      = true
    node_count                   = var.infra_node_count
    vm_size                      = var.infrapool_size
    orchestrator_version         = var.k8s_version
    os_disk_size_gb              = "500"
    pod_subnet_id                = var.pod_subnet_id
    vnet_subnet_id               = var.infrapool_subnet_id
    max_pods                     = var.infra_max_pods
    zones                        = var.infra_zones
    fips_enabled                 = false
    node_labels                  = var.node_infra_labels

    upgrade_settings {
      drain_timeout_in_minutes = "30"
      max_surge                = "10%"
    }

    tags = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  api_server_access_profile {
    authorized_ip_ranges = var.authorized_ip_ranges
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = false
    admin_group_object_ids = var.cluster_admin_group_ids
    tenant_id              = var.tenant_id
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      maintenance_window_auto_upgrade[0].start_date,
      maintenance_window_node_os[0].start_date
    ]
  }
}

resource "random_string" "node_pool_suffix" {
  length  = 2
  special = false
  numeric = true
  upper   = false
  lower   = false

  keepers = {
    vm_size              = var.workerpool_size
    os_disk_size_gb      = var.worker_pool_os_size_gb
    orchestrator_version = var.k8s_version
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "worker" {
  name                    = "workerpool${random_string.node_pool_suffix.result}"
  kubernetes_cluster_id   = azurerm_kubernetes_cluster.aks.id
  orchestrator_version    = var.k8s_version
  vm_size                 = var.workerpool_size
  os_disk_size_gb         = var.worker_pool_os_size_gb
  max_count               = var.worker_node_max_count
  min_count               = var.worker_node_min_count
  node_count              = var.worker_node_count
  pod_subnet_id           = var.pod_subnet_id
  vnet_subnet_id          = var.workerpool_subnet_id
  max_pods                = var.worker_max_pods
  zones                   = var.worker_zones
  fips_enabled            = false
  host_encryption_enabled = true
  auto_scaling_enabled    = var.worker_autoscaling_nodepool
  node_labels             = var.node_worker_labels
  tags                    = var.tags

  upgrade_settings {
    drain_timeout_in_minutes = "30"
    max_surge                = "10%"
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_role_assignment" "acrpull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_kubernetes_cluster_node_pool.worker
  ]
}

resource "azurerm_role_assignment" "managed_identity" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity.0.principal_id
  role_definition_name = "Contributor"
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg}"

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_kubernetes_cluster_node_pool.worker,
    azurerm_role_assignment.acrpull
  ]
}

resource "azurerm_management_lock" "aks_lock" {
  name       = "aks-lock"
  scope      = azurerm_kubernetes_cluster_node_pool.worker.id
  lock_level = "CanNotDelete"
  notes      = "Kubernetes cluster should not be deleted."

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_kubernetes_cluster_node_pool.worker,
    azurerm_role_assignment.acrpull,
    azurerm_role_assignment.managed_identity
  ]
}