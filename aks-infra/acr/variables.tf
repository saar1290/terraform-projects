variable "location" {
}

variable "name" {
}

variable "rg" {
}

variable "vnet_id" {
}

variable "subnet_id" {
}

variable "private_dns_zone_id" {
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "acr_network_rules" {
  type    = map(map(string))
  default = {}
}