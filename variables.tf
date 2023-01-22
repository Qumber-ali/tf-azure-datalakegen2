variable "location" {
  type        = string
  description = "Location to deploy data lake to."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy data lake to."
}

variable "data_lake_fs" {
  type = list(object({
    name = string
    dir_paths = list(object({
      path = string
      acls = optional(list(object({
        scope       = string
        type        = string
        id          = string
        permissions = string
        })
      ))
    }))
    acls = optional(list(object({
      scope       = string
      type        = string
      id          = string
      permissions = string
      })
    ))
    })
  )
  description = "List of data lake filesystem objects. Each object decribes the name of the filesystem which in turn is deployed as container in storage account, dir_paths to create in that filesystem along with the list of ACL objects for that path and also defines the list of ACLs at the filesystem root level. "
}

variable "storage_account" {
  type = object({
    name                     = string
    account_tier             = string
    account_replication_type = string
    account_kind             = string
    is_hns_enabled           = bool
  })
  description = "Storage account object containing storage account releted configs."
}

