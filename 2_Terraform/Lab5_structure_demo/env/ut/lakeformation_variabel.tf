variable "permission_configs" {
  description = "List of permission configurations"
  type = list(object({
    principal_type  = string           # "role" or "user"
    principal_name  = string           # Name of the role or user
    permission_type = number           # 1, 2, 3, etc. - references permission type in local.permissions_map
    resource_type   = optional(string) # Optional, defaults to "DATABASE"
    tag_expressions = list(object({
      key    = string
      values = list(string)
    }))
  }))

  default = []

  validation {
    condition = alltrue([
      for config in var.permission_configs :
      config.principal_type == "role" || config.principal_type == "user"
    ])
    error_message = "Principal type must be either 'role' or 'user'."
  }
}
