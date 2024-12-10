provider "akeyless" {
  api_gateway_address = "vault"

  api_key_login {
    access_id  = ""
    access_key = ""
  }
}

data "akeyless_static_secret" "sp_client_secret" {
  path = "sp_client_secret"
}

data "akeyless_static_secret" "sp_client_id" {
  path = "sp_client_id"
}

data "akeyless_static_secret" "sp_server_id" {
  path = "sp_server_id"
}

provider "azurerm" {
  features {}
  alias           = "production-dns"
  subscription_id = "prod-subscription-id"
  client_id       = data.akeyless_static_secret.sp_client_id.value
  client_secret   = data.akeyless_static_secret.sp_client_secret.value
  tenant_id       = var.tenant_id
}

data "azurerm_private_dns_zone" "private_dns_zone" {
  provider            = azurerm.production-dns
  name                = "privatelink.azurecr.io"
  resource_group_name = "dns-rg"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id     = var.subscription_id
  client_id           = data.akeyless_static_secret.sp_client_id.value
  client_secret       = data.akeyless_static_secret.sp_client_secret.value
  tenant_id           = var.tenant_id
  storage_use_azuread = true
}

provider "kubernetes" {
  host                   = module.aks.kube_config.0.host
  cluster_ca_certificate = base64decode(module.aks.kube_config.0.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--environment",
      "AzurePublicCloud",
      "--server-id",
      data.akeyless_static_secret.sp_server_id.value,
      "--client-id",
      data.akeyless_static_secret.sp_client_id.value,
      "--client-secret",
      data.akeyless_static_secret.sp_client_secret.value,
      "--tenant-id",
      var.tenant_id,
      "--login",
      "spn"
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.aks.kube_config.0.host
    cluster_ca_certificate = base64decode(module.aks.kube_config.0.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args = [
        "get-token",
        "--environment",
        "AzurePublicCloud",
        "--server-id",
        data.akeyless_static_secret.sp_server_id.value,
        "--client-id",
        data.akeyless_static_secret.sp_client_id.value,
        "--client-secret",
        data.akeyless_static_secret.sp_client_secret.value,
        "--tenant-id",
        var.tenant_id,
        "--login",
        "spn"
      ]
    }
  }
}

provider "kubectl" {
  host                   = module.aks.kube_config.0.host
  cluster_ca_certificate = base64decode(module.aks.kube_config.0.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--environment",
      "AzurePublicCloud",
      "--server-id",
      data.akeyless_static_secret.sp_server_id.value,
      "--client-id",
      data.akeyless_static_secret.sp_client_id.value,
      "--client-secret",
      data.akeyless_static_secret.sp_client_secret.value,
      "--tenant-id",
      var.tenant_id,
      "--login",
      "spn"
    ]
  }
  load_config_file = false
}