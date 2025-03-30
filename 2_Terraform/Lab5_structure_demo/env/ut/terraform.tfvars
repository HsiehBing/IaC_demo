# ========================= Basic information =========================

project     = "terraform-demo"
region      = "ap-northeast-1"
global_tags = { ManageByTerraform = "true", Env = "poc" }

# ========================== VPC ==========================
vpc_cidr                       = "10.0.0.0/16"
availability_zones             = ["ap-northeast-1", "ap-northeast-1c"]
public_subnet_cidrs            = ["10.0.0.0/24", "10.0.1.0/24", "10.0.7.0/24", "10.0.11.0/24"]
shared_private_subnet_cidrs    = ["10.0.2.0/24", "10.0.3.0/24", "10.0.8.0/24", "10.0.12.0/24"]
eks_control_plane_subnet_cidrs = ["10.0.4.0/25", "10.0.4.128/25", "10.0.9.0/24", "10.0.13.0/24"]
eks_worker_node_subnet_cidrs   = ["10.0.5.0/24", "10.0.6.0/24", "10.0.10.0/24", "10.0.14.0/24"]
single_nat_gateway             = true
vpc_default_tags               = {}

# ========================== Terraform permission ==========================
permission_configs = [
  {
    principal_type  = "role"           # "role" or "user"
    principal_name  = "bing-ec2-admin" # Name of the role
    permission_type = 1                # 1 for basic permissions
    tag_expressions = [{ key = "Team", values = ["Sales"] }, { key = "Environment", values = ["Dev", "Production"] }]
  }
  ,
  {
    principal_type  = "user"    # "role" or "user"
    principal_name  = "evatest" # Name of the user
    permission_type = 2         # 2 for advanced permissions
    tag_expressions = [{ key = "Team", values = ["Engineering"] }, { key = "Environment", values = ["Dev"] }]
  }
]
