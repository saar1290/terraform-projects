variable "location" {
}

variable "tenant_id" {
}

variable "subscription_id" {
}

variable "rg" {
}

variable "cluster_name" {
}

variable "cluster_id" {
}

variable "principal_id" {
}

variable "pod_subnet_id" {
}

variable "infrapool_subnet_id" {
}

variable "workerpool_subnet_id" {
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

variable "tags" {
  type    = map(string)
  default = {}
}