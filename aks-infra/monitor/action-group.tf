resource "azurerm_monitor_action_group" "auto_upgrade" {
  name                = "${var.cluster_name}-auto-upgrade"
  resource_group_name = var.rg
  short_name          = "autoupgrade"

  dynamic "email_receiver" {
    for_each = var.email_receivers
    content {
      email_address           = email_receiver.value
      name                    = "${trim(email_receiver.value, "@zim.com")}-notifications"
      use_common_alert_schema = true
    }
  }
}
