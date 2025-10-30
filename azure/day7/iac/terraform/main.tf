terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = ">= 3.0.0" }
    random  = { source = "hashicorp/random",  version = "~> 3.6" }
    time    = { source = "hashicorp/time",    version = "~> 0.11" }
    local   = { source = "hashicorp/local",   version = "~> 2.5" }
    null    = { source = "hashicorp/null",    version = "~> 3.2" }
  }
}

provider "azurerm" {
  features {}
  use_cli         = true
  subscription_id = "56d9a9d0-65a3-4aea-9957-ff103f641f9c"
  tenant_id       = "53f27eb2-cd38-4ce1-9efe-ec5e28cbf021"
}

data "azurerm_client_config" "me" {}

resource "random_string" "suf" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "rg" {
  name     = "mc-kms-day7-az-rg"
  location = "eastus2"
}

resource "azurerm_key_vault" "kv" {
  name                        = "mcday7kv${random_string.suf.result}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.me.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
}

resource "azurerm_key_vault_access_policy" "me" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.me.tenant_id
  object_id    = data.azurerm_client_config.me.object_id

  key_permissions = [
    "Get","List","Create","Update","Delete","Recover","Backup","Restore","Purge",
    "WrapKey","UnwrapKey","Encrypt","Decrypt",
    "GetRotationPolicy","SetRotationPolicy"
  ]
}

# small delay to let policy propagate
resource "time_sleep" "wait_perm" {
  depends_on      = [azurerm_key_vault_access_policy.me]
  create_duration = "20s"
}

resource "azurerm_key_vault_key" "key" {
  name         = "mc-day7-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["wrapKey","unwrapKey","encrypt","decrypt"]
  depends_on   = [time_sleep.wait_perm]
}

# --- Fallback: apply rotation policy using Azure CLI ---
# Write desired rotation policy as JSON
resource "local_file" "kv_rotation_policy" {
  filename = "${path.module}/policy.json"
  content = jsonencode({
    lifetimeActions = [
      {
        trigger = { timeAfterCreate = "P90D" }
        action  = { type = "Rotate" }
      },
      {
        trigger = { timeBeforeExpiry = "P30D" }
        action  = { type = "Notify" }
      }
    ]
    attributes = { expiryTime = "P180D" }
  })
}

# Apply policy via az CLI after key exists
resource "null_resource" "apply_rotation_policy" {
  depends_on = [azurerm_key_vault_key.key, local_file.kv_rotation_policy]

  provisioner "local-exec" {
    command = <<EOT
az keyvault key rotation-policy update \
  --vault-name ${azurerm_key_vault.kv.name} \
  --name ${azurerm_key_vault_key.key.name} \
  --value ${path.module}/policy.json
EOT
  }
}

output "azure_vault_name" { value = azurerm_key_vault.kv.name }
output "azure_key_name"   { value = azurerm_key_vault_key.key.name }
