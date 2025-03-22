# Project name
variable "project_name" {
  type    = string
  default = "bing-project" # 可以是 public 或其他環境名稱
}

variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "az" {
  type    = string
  default = "ap-northeast-1a"
}
#============================= VPC =============================

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "bing-vpc-terraform"
}

locals {
  default_route_table_name = "${var.project_name}-default-route-table"
}


#============================= subnet =============================
# Public Subnet

variable "public_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    "subnet1" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "ap-northeast-1a"
    }
    "subnet2" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "ap-northeast-1c"
    }
  }
}

# Private Subnet
variable "vpc_private_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    "subnet1" = {
      cidr_block        = "10.0.5.0/24"
      availability_zone = "ap-northeast-1a"
    }
    "subnet2" = {
      cidr_block        = "10.0.6.0/24"
      availability_zone = "ap-northeast-1c"
    }
  }
}

