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
    key            = "emr_2/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-state"
  }
}

# =========== ECR ===========

resource "aws_ecr_repository" "this" {
  for_each = var.repositories

  name                 = each.key
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  tags = each.value.tags
}

locals {
  # 預處理 lifecycle_rules 來確保所有欄位都正確設置
  repositories_with_lifecycle = {
    for k, v in var.repositories : k => v
    if length(v.lifecycle_rules) > 0
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = local.repositories_with_lifecycle

  repository = aws_ecr_repository.this[each.key].name

  # 使用 jsonencode 將 HCL 結構轉換為 JSON 字符串
  policy = jsonencode({
    rules = [
      for rule in each.value.lifecycle_rules : {
        rulePriority = rule.rule_priority
        description  = rule.description
        selection = merge(
          {
            tagStatus   = rule.tag_status
            countType   = rule.count_type
            countNumber = rule.count_number
          },
          # 有條件地加入 tagPrefixList 欄位 - 只有在 tagStatus 為 "tagged" 時
          rule.tag_status == "tagged" ? { tagPrefixList = rule.tag_prefix_list } : {},

          # 有條件地加入 countUnit 欄位 - 只有在 countType 為 "sinceImagePushed" 時
          rule.count_type == "sinceImagePushed" ? { countUnit = "days" } : {}
        )
        action = {
          type = "expire"
        }
      }
    ]
  })
}
