locals {
  tags = {
    "Application Name"  = "AKS"
    "Application Owner" = "MSO"
    "Infra Owner"       = "MSO"
    "Business Owner"    = "MSO"
    Environment         = var.environment
    DR                  = "true"
    ManagedBy           = "Terraform"
  }
}

variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "rg" {
  type = string
}

variable "location" {
}

variable "environment" {
  type = string
}

variable "vnet" {
  type = string
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet
  resource_group_name = var.rg
}

data "azurerm_subnet" "ep_subnet" {
  name                 = "Endpoints"
  virtual_network_name = var.vnet
  resource_group_name  = var.rg
}

data "azurerm_subnet" "pod_subnet" {
  name                 = "PODS-POOL"
  virtual_network_name = var.vnet
  resource_group_name  = var.rg
}

data "azurerm_subnet" "infra_subnet" {
  name                 = "INFRA-POOL"
  virtual_network_name = var.vnet
  resource_group_name  = var.rg
}

data "azurerm_subnet" "worker_subnet" {
  name                 = "WORKER-POOL"
  virtual_network_name = var.vnet
  resource_group_name  = var.rg
}

variable "acr_name" {
  type = string
}

variable "acr_network_rules" {
  type = map(map(string))
}

variable "cluster_name" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "service_cidr" {
  type = string
}

variable "dns_service_ip" {
  type = string
}

variable "infra_node_count" {
  type = number
}

variable "infra_max_pods" {
  type = number
}

variable "worker_node_count" {
  type = number
}

variable "worker_node_max_count" {
  type = number
}

variable "worker_node_min_count" {
  type = number
}

variable "worker_max_pods" {
  type = number
}

variable "worker_autoscaling_nodepool" {
  type = bool
}

variable "infrapool_size" {
  type = string
}

variable "infra_zones" {
  type    = list(number)
  default = []
}

variable "workerpool_size" {
  type = string
}

variable "worker_pool_os_size_gb" {
  type = string
}

variable "worker_zones" {
  type    = list(number)
  default = []
}

variable "topology_zone_values" {
  type = list(string)
}

variable "image_cleaner_interval_hours" {
  type = number
}

variable "upgrade_channel" {
}

variable "backup_name" {
  default = ""
}

variable "backup_repeating_time_interval" {
  type    = list(string)
  default = []
}

variable "backup_retention_days" {
  default = ""
}

variable "authorized_ip_ranges" {
  type = list(string)
}

variable "cluster_admin_group_ids" {
  type = list(string)
}

variable "loadBalancerIP" {
  type = string
}

locals {
  loadBalancerSubnetName = data.azurerm_subnet.worker_subnet.name
}

variable "cert_public_name" {
  type = string
}

variable "cert_private_name" {
  type = string
}

variable "infra_labels" {
  type = map(string)
}

variable "worker_labels" {
  type = map(string)
}

variable "aks_backup_enabled" {
  type    = bool
  default = true
}

variable "email_receivers" {
  type = list(string)
}

variable "custom_node_pool" {
  type = bool
}

variable "maintenance" {
  type = object({
    allowed_day         = optional(string)
    allowed_hours       = optional(set(number))
    frequency           = optional(string)
    frequency_node_os   = optional(string)
    duration            = optional(number)
    duration_node_os    = optional(number)
    interval            = optional(number)
    interval_node_os    = optional(number)
    utc_offset          = optional(string)
    start_time          = optional(string)
    day_of_week         = optional(string)
    day_of_week_node_os = optional(string)
  })
}

variable "node_pools" {
  type = list(object({
    name                = string
    mode                = string
    node_count          = number
    vm_size             = string
    zones               = list(number)
    enable_auto_scaling = bool
    max_count           = optional(number)
    min_count           = optional(number)
    max_pods            = number
    kubelet_disk_type   = optional(string)
    fips_enabled        = bool
    gpu_instance        = optional(string)
    ultra_ssd_enabled   = optional(bool)
    os_disk_size_gb     = optional(number)
    os_disk_type        = optional(string)
    os_sku              = optional(string)
    os_type             = optional(string)
    node_labels         = map(string)
    node_taints         = optional(list(string))
  }))
}