module "acr" {
  source              = "./acr"
  name                = var.acr_name
  location            = var.location
  rg                  = var.rg
  subnet_id           = data.azurerm_subnet.ep_subnet.id
  tags                = local.tags
  vnet_id             = data.azurerm_virtual_network.vnet.id
  acr_network_rules   = var.acr_network_rules
  private_dns_zone_id = data.azurerm_private_dns_zone.private_dns_zone.id
}

module "aks" {
  source                       = "./aks"
  cluster_name                 = var.cluster_name
  tenant_id                    = var.tenant_id
  location                     = var.location
  subscription_id              = var.subscription_id
  rg                           = var.rg
  k8s_version                  = var.k8s_version
  upgrade_channel              = var.upgrade_channel
  image_cleaner_interval_hours = var.image_cleaner_interval_hours
  dns_prefix                   = var.cluster_name
  pod_subnet_id                = data.azurerm_subnet.pod_subnet.id
  service_cidr                 = var.service_cidr
  dns_service_ip               = var.dns_service_ip
  infrapool_size               = var.infrapool_size
  infra_zones                  = var.infra_zones
  workerpool_size              = var.workerpool_size
  worker_pool_os_size_gb       = var.worker_pool_os_size_gb
  worker_zones                 = var.worker_zones
  infrapool_subnet_id          = data.azurerm_subnet.infra_subnet.id
  workerpool_subnet_id         = data.azurerm_subnet.worker_subnet.id
  infra_node_count             = var.infra_node_count
  infra_max_pods               = var.infra_max_pods
  worker_node_max_count        = var.worker_node_max_count
  worker_node_min_count        = var.worker_node_min_count
  worker_node_count            = var.worker_node_count
  worker_max_pods              = var.worker_max_pods
  worker_autoscaling_nodepool  = var.worker_autoscaling_nodepool
  topology_zone_values         = var.topology_zone_values
  tags                         = local.tags
  authorized_ip_ranges         = var.authorized_ip_ranges
  cluster_admin_group_ids      = var.cluster_admin_group_ids
  acr_id                       = module.acr.id
  sp_client_id                 = nonsensitive(data.akeyless_static_secret.sp_client_id.value)
  sp_client_secret             = nonsensitive(data.akeyless_static_secret.sp_client_secret.value)
  node_worker_labels           = var.worker_labels
  node_infra_labels            = var.infra_labels
  custom_node_pool             = var.custom_node_pool
  node_pools                   = var.node_pools
  maintenance                  = var.maintenance

  depends_on = [
    module.acr,
  ]
}

module "cert_manager_issuer" {
  source  = "./issuer"
  public  = var.cert_public_name
  private = var.cert_private_name

  depends_on = [
    module.acr,
    module.aks
  ]
}

module "calico_policy" {
  source = "./calico"

  depends_on = [
    module.acr,
    module.aks,
    module.cert_manager_issuer
  ]
}

module "ingress-controller" {
  source                 = "./ingress-controller"
  loadBalancerIP         = var.loadBalancerIP
  loadBalancerSubnetName = local.loadBalancerSubnetName

  depends_on = [
    module.acr,
    module.aks,
    module.cert_manager_issuer,
    module.calico_policy
  ]
}

module "extra-manifests" {
  source = "./extra-manifests"

  depends_on = [
    module.acr,
    module.aks,
    module.cert_manager_issuer,
    module.calico_policy,
    module.ingress-controller
  ]
}

module "aks-backup" {
  count                          = var.aks_backup_enabled == true ? 1 : 0
  source                         = "./aks-backup"
  tenant_id                      = var.tenant_id
  location                       = var.location
  subscription_id                = var.subscription_id
  rg                             = var.rg
  cluster_id                     = module.aks.cluster_id
  principal_id                   = module.aks.principal_id
  backup_name                    = var.backup_name
  backup_repeating_time_interval = var.backup_repeating_time_interval
  backup_retention_days          = var.backup_retention_days
  cluster_name                   = var.cluster_name
  infrapool_subnet_id            = data.azurerm_subnet.infra_subnet.id
  workerpool_subnet_id           = data.azurerm_subnet.worker_subnet.id
  pod_subnet_id                  = data.azurerm_subnet.pod_subnet.id
  tags                           = local.tags

  depends_on = [
    module.acr,
    module.aks,
    module.cert_manager_issuer,
    module.calico_policy,
    module.ingress-controller,
    module.extra-manifests
  ]
}

module "monitor" {
  source          = "./monitor"
  location        = var.location
  rg              = var.rg
  cluster_name    = module.aks.cluster_name
  cluster_id      = module.aks.cluster_id
  tags            = local.tags
  email_receivers = var.email_receivers

  depends_on = [
    module.acr,
    module.aks,
    module.cert_manager_issuer,
    module.calico_policy,
    module.ingress-controller,
    module.extra-manifests,
    module.aks-backup
  ]
}
