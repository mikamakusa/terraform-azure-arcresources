module "storage" {
  source              = "./modules/terraform-azure-storage"
  resource_group_name = data.azurerm_resource_group.this.name
}