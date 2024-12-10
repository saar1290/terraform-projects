resource "azurerm_monitor_activity_log_alert" "mc_auto_upgrade" {
  name                = "${var.cluster_name}-mc-update-alerts"
  resource_group_name = var.rg
  location            = var.location
  scopes              = [var.cluster_id]
  description         = "This alert will monitor aks cluster update or upgrade events."

  criteria {
    resource_id    = var.cluster_id
    operation_name = "Microsoft.ContainerService/managedClusters/write"
    category       = "Administrative"
    levels = [
      "Informational",
      "Warning",
      "Error",
      "Critical",
      "Verbose"
    ]
    statuses = [
      "Started",
      "Failed",
      "Succeeded"
    ]
  }

  action {
    action_group_id = azurerm_monitor_action_group.auto_upgrade.id

    webhook_properties = {
      from = "terraform"
    }
  }

  tags = var.tags
}