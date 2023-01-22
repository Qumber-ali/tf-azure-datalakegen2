## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.39.1 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.9.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.client_contributor_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.client_owner_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_data_lake_gen2_filesystem.data_lake_fs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_data_lake_gen2_filesystem) | resource |
| [azurerm_storage_data_lake_gen2_path.directories](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_data_lake_gen2_path) | resource |
| [time_sleep.adls_ra_delay](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_lake_fs"></a> [data\_lake\_fs](#input\_data\_lake\_fs) | List of data lake filesystem objects. Each object decribes the name of the filesystem which in turn is deployed as container in storage account, dir\_paths to create in that filesystem along with the list of ACL objects for that path and also defines the list of ACLs at the filesystem root level. | <pre>list(object({<br>    name = string<br>    dir_paths = list(object({<br>      path = string<br>      acls = optional(list(object({<br>        scope       = string<br>        type        = string<br>        id          = string<br>        permissions = string<br>        })<br>      ))<br>    }))<br>    acls = optional(list(object({<br>      scope       = string<br>      type        = string<br>      id          = string<br>      permissions = string<br>      })<br>    ))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location to deploy data lake to. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to deploy data lake to. | `string` | n/a | yes |
| <a name="input_storage_account"></a> [storage\_account](#input\_storage\_account) | Storage account object containing storage account releted configs. | <pre>object({<br>    name                     = string<br>    account_tier             = string<br>    account_replication_type = string<br>    account_kind             = string<br>    is_hns_enabled           = bool<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
