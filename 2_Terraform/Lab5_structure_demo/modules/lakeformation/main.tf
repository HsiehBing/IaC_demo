# Create a flattened list of all permission type + resource type combinations
locals {
  # First, adjust the resource types based on provided configs
  adjusted_configs = [
    for idx, config in var.permission_configs : {
      idx           = idx
      principal_type = config.principal_type
      principal_name = config.principal_name
      permission_type = config.permission_type
      # Remove explicit resource_type to allow for both DATABASE and TABLE resources
      resource_type  = null  
      tag_expressions = config.tag_expressions
    }
  ]
  
  # Generate all permission combinations for both DATABASE and TABLE
  permission_combinations = flatten([
    # For each permission config, create entries for each resource type
    for idx, config in local.adjusted_configs : [
      # Database entry
      {
        key        = "${idx}-database"
        config     = config
        res_type   = "DATABASE"
      },
      # Table entry
      {
        key        = "${idx}-table"
        config     = config
        res_type   = "TABLE"
      }
    ]
  ])

  # Filter out combinations that don't have permissions defined
  valid_permissions = {
    for pair in local.permission_combinations :
    pair.key => pair
    if length(lookup(
      lookup(local.permissions_map, pair.config.permission_type, {}),
      pair.res_type,
      []
    )) > 0
  }
}

# Generic LF permissions resource that handles both database and table permissions based on type
resource "aws_lakeformation_permissions" "lf_permissions" {
  # Create resources only for valid permission combinations
  for_each = local.valid_permissions

  # Set principal based on type
  principal = each.value.config.principal_type == "role" ? (
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${each.value.config.principal_name}"
  ) : (
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${each.value.config.principal_name}"
  )

  # Get permissions from the map based on permission type and resource type
  permissions = lookup(
    lookup(local.permissions_map, each.value.config.permission_type, {}),
    each.value.res_type,
    []
  )

  lf_tag_policy {
    resource_type = each.value.res_type

    dynamic "expression" {
      for_each = each.value.config.tag_expressions
      content {
        key    = expression.value.key
        values = expression.value.values
      }
    }
  }
}

# Get AWS account ID for ARN construction
data "aws_caller_identity" "current" {}
