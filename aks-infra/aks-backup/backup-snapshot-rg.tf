resource "azurerm_resource_group" "aks_backup_snapshot" {
  name     = "${var.rg}-snapshoot"
  location = var.location
  tags     = var.tags
}