provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      createby = "terraform"
      JRID     = "PS2408025"
    }
  }
}

terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "bing-terraform-backend-202533532893"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-state"
  }
}

###########################################
# VPC
###########################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  tags = {
    Name        = local.default_route_table_name # 這裡設定名稱
    Description = "Default route table"
    ManagedBy   = "Terraform"
    DoNotUse    = "true"
  }
}



