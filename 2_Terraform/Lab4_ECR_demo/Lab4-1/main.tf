provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      createby = "terraform"
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

# =========== ECR ===========
resource "aws_ecr_repository" "this" {
  name                 = "bing-1"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = { env : "test" }
}


resource "aws_ecr_lifecycle_policy" "example" {
  repository = "bing-1"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
