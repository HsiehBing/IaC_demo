locals {
  # Permission mappings by type and resource type
  permissions_map = {
    # Type 1 permissions
    1 = {
      DATABASE = ["DESCRIBE"]
      TABLE    = ["SELECT"]
    }
    # Type 2 permissions
    2 = {
      DATABASE = ["DESCRIBE", "CREATE_TABLE", "ALTER", "DROP"]
      TABLE    = ["SELECT", "INSERT", "DESCRIBE"]
    }
    # Type 3 permissions - Example for future use
    3 = {
      DATABASE = ["DESCRIBE", "CREATE_TABLE"]
      TABLE    = ["SELECT", "INSERT", "DELETE", "DESCRIBE"]
    }
  }
}
