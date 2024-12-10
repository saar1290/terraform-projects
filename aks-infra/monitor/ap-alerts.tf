resource "azurerm_monitor_activity_log_alert" "ap_auto_upgrade" {
  name                = "${var.cluster_name}-ap-update-alerts"
  resource_group_name = "MC_${var.rg}_${var.cluster_name}_${lower(replace(var.location, " ", ""))}"
  location            = var.location
  scopes              = [var.cluster_id]
  description         = "This alert will monitor agent pools update or upgrade events."

  criteria {
    resource_id    = var.cluster_id
    operation_name = "Microsoft.ContainerService/managedClusters/agentPools/upgradeNodeImageVersion/action"
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