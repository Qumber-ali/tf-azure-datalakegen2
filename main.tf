terraform {
 required_version = ">=0.13.0"
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

locals {
  path_obj = flatten([for fs in var.data_lake_fs : [
    for paths in fs["dir_paths"] : {
      file_system = fs["name"]
      dir_paths   = paths["path"]
      dir_acls    = paths["acls"]
    }
    ]
  ])
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account["name"]
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.storage_account["account_tier"]
  account_replication_type = var.storage_account["account_replication_type"]
  account_kind             = var.storage_account["account_kind"]
  is_hns_enabled           = var.storage_account["is_hns_enabled"]
}

resource "time_sleep" "adls_ra_delay" {
  create_duration = "20s"

  triggers = {
    sa_contributor_role_assignment = azurerm_role_assignment.client_contributor_role_assignment.id
    sa_owner_role_assignment       = azurerm_role_assignment.client_owner_role_assignment.id
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "data_lake_fs" {
  count = length(var.data_lake_fs)

  name               = var.data_lake_fs[count.index]["name"]
  storage_account_id = azurerm_storage_account.storage_account.id
  owner              = "fc43379f-d8d7-4e28-8336-90e5556ba63f"
  group              = "fc43379f-d8d7-4e28-8336-90e5556ba63f"

  dynamic "ace" {
    for_each = var.data_lake_fs[count.index]["acls"] != null ? { for index, fs_acls in var.data_lake_fs[count.index]["acls"] : index => fs_acls } : {}

    content {
      scope       = ace.value["scope"]
      type        = ace.value["type"]
      id          = ace.value["id"]
      permissions = ace.value["permissions"]
    }
  }

  depends_on = [azurerm_role_assignment.client_contributor_role_assignment, azurerm_role_assignment.client_owner_role_assignment, time_sleep.adls_ra_delay]
}

resource "azurerm_role_assignment" "client_contributor_role_assignment" {
  scope                = azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "client_owner_role_assignment" {
  scope                = azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_storage_data_lake_gen2_path" "directories" {
  for_each = { for i, paths in local.path_obj : tostring(i) => paths }

  path               = each.value["dir_paths"]
  filesystem_name    = each.value["file_system"]
  storage_account_id = azurerm_storage_account.storage_account.id
  resource           = "directory"
  owner              = "fc43379f-d8d7-4e28-8336-90e5556ba63f"
  group              = "fc43379f-d8d7-4e28-8336-90e5556ba63f"

  dynamic "ace" {
    for_each = each.value["dir_acls"] != null ? { for index, dir_acls in each.value["dir_acls"] : index => dir_acls } : {}

    content {
      scope       = ace.value["scope"]
      type        = ace.value["type"]
      id          = ace.value["id"]
      permissions = ace.value["permissions"]
    }
  }

  depends_on = [azurerm_storage_data_lake_gen2_filesystem.data_lake_fs]
}
