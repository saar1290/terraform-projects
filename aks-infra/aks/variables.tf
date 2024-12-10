variable "location" {
}

variable "subscription_id" {
}

variable "rg" {
}

variable "cluster_name" {
}

variable "k8s_version" {
}

variable "infra_node_count" {
}

variable "infra_max_pods" {
}

variable "infrapool_subnet_id" {
}

variable "worker_node_count" {
}

variable "worker_node_max_count" {
}

variable "worker_node_min_count" {
}

variable "worker_max_pods" {
}

variable "workerpool_subnet_id" {
}

variable "worker_autoscaling_nodepool" {
}

variable "infrapool_size" {
}

variable "infra_zones" {
  type    = list(number)
  default = []
}

variable "workerpool_size" {
}

variable "worker_pool_os_size_gb" {
}

variable "worker_zones" {
  type    = list(number)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "authorized_ip_ranges" {
}

variable "cluster_admin_group_ids" {
}

variable "acr_id" {
}

variable "pod_subnet_id" {
}

variable "service_cidr" {
}

variable "dns_service_ip" {
}

variable "dns_prefix" {
}

variable "tenant_id" {
}

variable "sp_client_id" {
}

variable "sp_client_secret" {
}

variable "node_worker_labels" {
  type    = map(string)
  default = {}
}

variable "node_infra_labels" {
  type    = map(string)
  default = {}
}

variable "topology_zone_values" {
  type = list(string)
}

variable "image_cleaner_interval_hours" {
  type = number
}

variable "upgrade_channel" {
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