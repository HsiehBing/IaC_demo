# ====================== global ======================
variable "region" {
  description = "Default AWS region"
  type        = string
}

variable "project" {
  description = "project name"
  type        = string
}
variable "global_tags" {
  description = "Global tags"
  type        = map(string)
}

# ====================== VPC ======================

# 使用project
# variable "vpc_name" {
#   description = "VPC name"
#   type        = string
# }

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "shared_private_subnet_cidrs" {
  description = "CIDR blocks for shared private subnets"
  type        = list(string)
}

variable "eks_control_plane_subnet_cidrs" {
  description = "CIDR blocks for EKS control plane subnets"
  type        = list(string)
}

variable "eks_worker_node_subnet_cidrs" {
  description = "CIDR blocks for EKS worker node subnets"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
}

variable "vpc_default_tags" {
  description = "Global tags for all resources"
  type        = map(string)
}
