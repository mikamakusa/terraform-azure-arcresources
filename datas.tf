data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

data "azurerm_arc_machine" "this" {
  count               = try(var.azurerm_arc_machine_name ? 1 : 0)
  name                = try(var.azurerm_arc_machine_name)
  resource_group_name = data.azurerm_resource_group.this.name
}