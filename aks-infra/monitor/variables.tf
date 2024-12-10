variable "location" {
}

variable "rg" {
}

variable "cluster_name" {
}

variable "cluster_id" {
}

variable "email_receivers" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}