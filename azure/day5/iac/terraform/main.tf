terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.116" }
    random  = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  type    = string
  default = "eastus2" # moved from eastus due to LocationIsOfferRestricted
}

variable "rg_name" {
  type    = string
  default = "mc-kms-day5-az-rg-eus2"
}

variable "server_name_prefix" {
  type    = string
  default = "mcday5pg"
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_key_vault" "kv" {
  name                          = "mckv${random_string.suffix.result}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  tenant_id                     = "53f27eb2-cd38-4ce1-9efe-ec5e28cbf021"
  sku_name                      = "standard"
  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  public_network_access_enabled = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "me" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions    = ["Get", "Create", "List", "Update", "GetRotationPolicy"]
  secret_permissions = ["Get", "Set", "List"]
}

resource "azurerm_key_vault_key" "cmk" {
  name         = "pg-cmk"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]

  depends_on = [azurerm_key_vault_access_policy.me]
}

resource "azurerm_user_assigned_identity" "uami" {
  name                = "pg-cmk-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_key_vault_access_policy" "uami_policy" {
  key_vault_id    = azurerm_key_vault.kv.id
  tenant_id       = "53f27eb2-cd38-4ce1-9efe-ec5e28cbf021"
  object_id       = azurerm_user_assigned_identity.uami.principal_id
  key_permissions = ["Get", "WrapKey", "UnwrapKey"]
}

resource "random_password" "admin" {
  length  = 20
  special = true
}

resource "azurerm_key_vault_secret" "admin_secret" {
  name         = "pg-admin"
  value        = random_password.admin.result
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_key_vault_access_policy.me]
}

resource "azurerm_postgresql_flexible_server" "pg" {
  name                = "${var.server_name_prefix}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku_name                     = "B_Standard_B1ms"
  version                      = "16"
  storage_mb                   = 32768
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  zone                         = "1"

  administrator_login    = "pgadmin"
  administrator_password = random_password.admin.result

  public_network_access_enabled = true

  identity {
    type         = "UserAssigned" # provider requires UserAssigned when using CMK
    identity_ids = [azurerm_user_assigned_identity.uami.id]
  }

  # CMK wiring
  customer_managed_key {
    key_vault_key_id                  = azurerm_key_vault_key.cmk.id
    primary_user_assigned_identity_id = azurerm_user_assigned_identity.uami.id
  }

  tags = { "mc-lab" = "kms-day5" }
}

output "server_fqdn" { value = azurerm_postgresql_flexible_server.pg.fqdn }
output "admin_user" { value = azurerm_postgresql_flexible_server.pg.administrator_login }
output "key_vault_uri" { value = azurerm_key_vault.kv.vault_uri }
output "key_id" { value = azurerm_key_vault_key.cmk.id }
