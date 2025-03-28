# ========================= Basic information =========================

project     = "bison-poc-eks"
region      = "us-east-1"
global_tags = { ManageByTerraform = "true", Env = "poc" }

# ========================== VPC ==========================
vpc_cidr                       = "10.0.0.0/16"
availability_zones             = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs            = ["10.0.0.0/24", "10.0.1.0/24", "10.0.7.0/24", "10.0.11.0/24"]
shared_private_subnet_cidrs    = ["10.0.2.0/24", "10.0.3.0/24", "10.0.8.0/24", "10.0.12.0/24"]
eks_control_plane_subnet_cidrs = ["10.0.4.0/25", "10.0.4.128/25", "10.0.9.0/24", "10.0.13.0/24"]
eks_worker_node_subnet_cidrs   = ["10.0.5.0/24", "10.0.6.0/24", "10.0.10.0/24", "10.0.14.0/24"]
single_nat_gateway             = false
vpc_default_tags               = {}
