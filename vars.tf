## TAGS

variable "tags" {
  type    = map(string)
  default = {}
}

## DATAS

variable "resource_group_name" {
  type = string
}

variable "azurerm_arc_machine_name" {
  type    = string
  default = null
}

## RESOURCES

variable "kubernetes_cluster" {
  type = list(object({
    id                           = number
    agent_public_key_certificate = string
    name                         = string
    tags                         = optional(map(string))
  }))
  default = []
}

variable "kubernetes_cluster_extension" {
  type = list(object({
    id                               = number
    cluster_id                       = any
    extension_type                   = string
    name                             = string
    configuration_protected_settings = optional(map(string))
    configuration_settings           = optional(map(string))
    release_train                    = optional(string)
    release_namespace                = optional(string)
    target_namespace                 = optional(string)
    version                          = optional(string)
  }))
  default = []
}

variable "kubernetes_flux_configuration" {
  type = list(object({
    id                                = number
    cluster_id                        = any
    name                              = string
    namespace                         = string
    scope                             = optional(string)
    continuous_reconciliation_enabled = optional(bool)
    kustomizations = list(object({
      name                       = string
      path                       = optional(string)
      timeout_in_seconds         = optional(number)
      sync_interval_in_seconds   = optional(number)
      retry_interval_in_seconds  = optional(number)
      recreating_enabled         = optional(bool)
      garbage_collection_enabled = optional(bool)
      depends_on                 = optional(list(string))
    }))
    blob_storage = optional(list(object({
      container_id             = any
      account_key              = optional(string)
      local_auth_reference     = optional(string)
      sas_token                = optional(string)
      sync_interval_in_seconds = optional(number)
      timeout_in_seconds       = optional(number)
      service_principal = optional(list(object({
        client_id                     = string
        tenant_id                     = string
        client_certificate_base64     = optional(string)
        client_certificate_password   = optional(string)
        client_certificate_send_chain = optional(bool)
        client_secret                 = optional(string)
      })))
    })))
    bucket = optional(list(object({
      bucket_name              = any
      url                      = string
      access_key               = optional(string)
      secret_key_base64        = optional(string)
      local_auth_reference     = optional(string)
      sync_interval_in_seconds = optional(number)
      timeout_in_seconds       = optional(number)
      tls_enabled              = optional(bool)
    })))
    git_repository = optional(list(object({
      reference_type           = string
      reference_value          = string
      url                      = string
      https_ca_cert_base64     = optional(string)
      https_key_base64         = optional(string)
      https_user               = optional(string)
      local_auth_reference     = optional(string)
      ssh_known_hosts_base64   = optional(string)
      ssh_private_key_base64   = optional(string)
      sync_interval_in_seconds = optional(number)
      timeout_in_seconds       = optional(number)
    })))
  }))
  default = []
}

variable "machine_extension" {
  type = list(object({
    id                        = number
    name                      = string
    publisher                 = string
    type                      = string
    automatic_upgrade_enabled = optional(bool)
    force_update_tag          = optional(string)
    protected_settings        = optional(string)
    settings                  = optional(string)
    tags                      = optional(map(string))
    type_handler_version      = optional(string)
  }))
  default = []
}

variable "private_link_scope" {
  type = list(object({
    id                            = number
    name                          = string
    public_network_access_enabled = optional(bool)
    tags                          = optional(map(string))
  }))
  default = []
}

variable "resource_bridge_appliance" {
  type = list(object({
    id                      = number
    distro                  = string
    infrastructure_provider = string
    name                    = string
    public_key_base64       = optional(string)
    tags                    = optional(map(string))
  }))
  default = []
}
