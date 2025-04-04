#========================== Provider ==========================
provider "aws" {
  region = var.region
  default_tags {
    tags = var.global_tags
  }
}

terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.88"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.35"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17"
    }
  }

  #========================== backend ==========================
  #   backend "s3" {
  #     bucket         = "bing-terraform-backend-202533532893"
  #     key            = "emr/terraform.tfstate"
  #     region         = "ap-northeast-1"
  #     dynamodb_table = "terraform-state"
  #   }
  # }

  backend "s3" {
    bucket         = "bing-369432261332-terraform-state-tokyo"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-state"
  }
}

# ========================== modules ==========================
# =========== vpc ===========
# module "vpc" {
#   source                         = "../../modules/vpc"
#   project                        = var.project
#   vpc_cidr                       = var.vpc_cidr
#   availability_zones             = var.availability_zones
#   public_subnet_cidrs            = var.public_subnet_cidrs
#   shared_private_subnet_cidrs    = var.shared_private_subnet_cidrs
#   eks_control_plane_subnet_cidrs = var.eks_control_plane_subnet_cidrs
#   eks_worker_node_subnet_cidrs   = var.eks_worker_node_subnet_cidrs
#   single_nat_gateway             = var.single_nat_gateway
#   vpc_default_tags               = var.vpc_default_tags
# }

# =========== lakeformation ===========
module "lakeformation" {
  source             = "../../modules/lakeformation"
  permission_configs = var.permission_configs
}

