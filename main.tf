resource "azurerm_arc_kubernetes_cluster" "this" {
  count                        = length(var.kubernetes_cluster)
  agent_public_key_certificate = filebase64(join("/", [path.cwd, "certificates", lookup(var.kubernetes_cluster[count.index], "agent_public_key_certificate")]))
  location                     = data.azurerm_resource_group.this.location
  name                         = lookup(var.kubernetes_cluster[count.index], "name")
  resource_group_name          = data.azurerm_resource_group.this.name
  tags                         = merge(var.tags, lookup(var.kubernetes_cluster[count.index], "tags"))
  
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_arc_kubernetes_cluster_extension" "this" {
  count                            = length(var.kubernetes_cluster) == 0 ? 0 : length(var.kubernetes_cluster_extension)
  cluster_id                       = try(element(azurerm_arc_kubernetes_cluster.this.*.id, lookup(var.kubernetes_cluster_extension[count.index], "cluster_id")))
  extension_type                   = lookup(var.kubernetes_cluster_extension[count.index], "extension_type")
  name                             = lookup(var.kubernetes_cluster_extension[count.index], "name")
  configuration_protected_settings = lookup(var.kubernetes_cluster_extension[count.index], "configuration_protected_settings")
  configuration_settings           = lookup(var.kubernetes_cluster_extension[count.index], "configuration_settings")
  release_train                    = lookup(var.kubernetes_cluster_extension[count.index], "release_train")
  release_namespace                = lookup(var.kubernetes_cluster_extension[count.index], "release_namespace")
  target_namespace                 = lookup(var.kubernetes_cluster_extension[count.index], "target_namespace")
  version                          = lookup(var.kubernetes_cluster_extension[count.index], "version")

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_arc_kubernetes_flux_configuration" "this" {
  count                             = (length(var.kubernetes_cluster_extension) && length(var.kubernetes_cluster)) == 0 ? 0 : length(var.kubernetes_flux_configuration)
  cluster_id                        = try(element(azurerm_arc_kubernetes_cluster.this.*.id, lookup(var.kubernetes_flux_configuration[count.index], "cluster_id")))
  name                              = lookup(var.kubernetes_flux_configuration[count.index], "name")
  namespace                         = lookup(var.kubernetes_flux_configuration[count.index], "namespace")
  scope                             = lookup(var.kubernetes_flux_configuration[count.index], "scope")
  continuous_reconciliation_enabled = lookup(var.kubernetes_flux_configuration[count.index], "continuous_reconciliation_enabled")

  dynamic "kustomizations" {
    for_each = lookup(var.kubernetes_flux_configuration[count.index], "kustomizations")
    content {
      name                       = lookup(kustomizations.value, "name")
      path                       = lookup(kustomizations.value, "path")
      timeout_in_seconds         = lookup(kustomizations.value, "timeout_in_seconds")
      sync_interval_in_seconds   = lookup(kustomizations.value, "sync_interval_in_seconds")
      retry_interval_in_seconds  = lookup(kustomizations.value, "retry_interval_in_seconds")
      recreating_enabled         = lookup(kustomizations.value, "recreating_enabled")
      garbage_collection_enabled = lookup(kustomizations.value, "garbage_collection_enabled")
      depends_on                 = lookup(kustomizations.value, "depends_on")
    }
  }

  dynamic "blob_storage" {
    for_each = try(lookup(var.kubernetes_flux_configuration[count.index], "blob_storage") == null ? [] : ["blob_storage"])
    content {
      container_id             = ""
      account_key              = ""
      local_auth_reference     = lookup(blob_storage.value, "local_auth_reference")
      sas_token                = lookup(blob_storage.value, "sas_token")
      sync_interval_in_seconds = lookup(blob_storage.value, "sync_interval_in_seconds")
      timeout_in_seconds       = lookup(blob_storage.value, "timeout_in_seconds")

      dynamic "service_principal" {
        for_each = try(lookup(blob_storage.value, "service_principal"))
        content {
          client_id                     = sensitive(lookup(service_principal.value, "client_id"))
          tenant_id                     = sensitive(lookup(service_principal.value, "tenant_id"))
          client_certificate_base64     = filebase64(join("/", [path.cwd, "certificate", lookup(service_principal.value, "client_certificate_base64")]))
          client_certificate_password   = sensitive(lookup(service_principal.value, "client_certificate_password"))
          client_certificate_send_chain = lookup(service_principal.value, "client_certificate_send_chain")
          client_secret                 = sensitive(lookup(service_principal.value, "client_secret"))
        }
      }
    }
  }

  dynamic "bucket" {
    for_each = try(lookup(var.kubernetes_flux_configuration[count.index], "bucket") == null ? [] : ["bucket"])
    content {
      bucket_name              = ""
      url                      = ""
      access_key               = ""
      secret_key_base64        = filebase64(join("/", [path.cwd, "certificate", lookup(bucket.value, "secret_key_base64")]))
      local_auth_reference     = lookup(bucket.value, "local_auth_reference")
      sync_interval_in_seconds = lookup(bucket.value, "sync_interval_in_seconds")
      timeout_in_seconds       = lookup(bucket.value, "timeout_in_seconds")
      tls_enabled              = lookup(bucket.value, "tls_enabled")
    }
  }

  dynamic "git_repository" {
    for_each = try(lookup(var.kubernetes_flux_configuration[count.index], "git_repository") == null ? [] : ["git_repository"])
    content {
      reference_type           = lookup(git_repository.value, "reference_type")
      reference_value          = lookup(git_repository.value, "reference_value")
      url                      = lookup(git_repository.value, "url")
      https_ca_cert_base64     = filebase64(join("/", [path.cwd, "certificate", lookup(git_repository.value, "https_ca_cert_base64")]))
      https_key_base64         = filebase64(join("/", [path.cwd, "certificate", lookup(git_repository.value, "https_key_base64")]))
      https_user               = lookup(git_repository.value, "https_user")
      local_auth_reference     = lookup(git_repository.value, "local_auth_reference")
      ssh_known_hosts_base64   = filebase64(join("/", [path.cwd, "certificate", lookup(git_repository.value, "ssh_known_hosts_base64")]))
      ssh_private_key_base64   = filebase64(join("/", [path.cwd, "certificate", lookup(git_repository.value, "ssh_private_key_base64")]))
      sync_interval_in_seconds = lookup(git_repository.value, "sync_interval_in_seconds")
      timeout_in_seconds       = lookup(git_repository.value, "timeout_in_seconds")
    }
  }
}

resource "azurerm_arc_machine_extension" "this" {
  count                     = length(var.machine_extension)
  arc_machine_id            = data.azurerm_arc_machine.this.id
  location                  = data.azurerm_resource_group.this.location
  name                      = lookup(var.machine_extension[count.index], "name")
  publisher                 = lookup(var.machine_extension[count.index], "publisher")
  type                      = lookup(var.machine_extension[count.index], "type")
  automatic_upgrade_enabled = lookup(var.machine_extension[count.index], "automatic_upgrade_enabled")
  force_update_tag          = lookup(var.machine_extension[count.index], "automatic_upgrade_enabled")
  protected_settings        = lookup(var.machine_extension[count.index], "force_update_tag")
  settings                  = lookup(var.machine_extension[count.index], "protected_settings")
  tags                      = merge(var.tags, lookup(var.machine_extension[count.index], "tags"))
  type_handler_version      = lookup(var.machine_extension[count.index], "settings")
}

resource "azurerm_arc_private_link_scope" "this" {
  count                         = length(var.private_link_scope)
  location                      = data.azurerm_resource_group.this.location
  name                          = lookup(var.private_link_scope[count.index], "name")
  resource_group_name           = data.azurerm_resource_group.this.name
  public_network_access_enabled = lookup(var.private_link_scope[count.index], "public_network_access_enabled")
  tags                          = merge(var.tags, lookup(var.private_link_scope[count.index], "tags"))
}

resource "azurerm_arc_resource_bridge_appliance" "this" {
  count                   = length(var.resource_bridge_appliance)
  distro                  = lookup(var.resource_bridge_appliance[count.index], "distro")
  infrastructure_provider = lookup(var.resource_bridge_appliance[count.index], "infrastructure_provider")
  location                = data.azurerm_resource_group.this.location
  name                    = lookup(var.resource_bridge_appliance[count.index], "name")
  resource_group_name     = data.azurerm_resource_group.this.name
  public_key_base64       = filebase64(join("/", [path.cwd, "certificate", lookup(var.resource_bridge_appliance[count.index], "public_key_base64")]))
  tags                    = merge(var.tags, lookup(var.resource_bridge_appliance[count.index], "tags"))

  identity {
    type = "SystemAssigned"
  }
}