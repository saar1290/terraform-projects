resource "azurerm_container_registry" "acr" {
  name                = var.name
  resource_group_name = var.rg
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = false

  dynamic "network_rule_set" {
    for_each = var.acr_network_rules[*]
    content {
      default_action = "Deny"

      dynamic "ip_rule" {
        for_each = network_rule_set.value
        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "acr_pe" {
  name                = "${var.name}-ACR-PE"
  location            = var.location
  resource_group_name = var.rg
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = azurerm_container_registry.acr.name
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "${var.name}-privatelink.azurecr.io"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags

  depends_on = [
    azurerm_container_registry.acr
  ]
}