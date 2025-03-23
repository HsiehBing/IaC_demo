variable "repositories" {
  description = "ECR 儲存庫配置"
  type = map(object({
    image_tag_mutability = optional(string, "MUTABLE")
    scan_on_push         = optional(bool, true)
    lifecycle_rules = optional(list(object({
      rule_priority   = number
      description     = optional(string)
      tag_status      = string
      tag_prefix_list = optional(list(string), [])
      count_type      = string
      count_number    = number
    })), [])
    tags = optional(map(string), {})
  }))
  default = {
    #=====================================================
    # Lobby 服務儲存庫
    #=====================================================
    "bing-ecr-1" = {
      lifecycle_rules = [
        # 規則 1: 清理舊的未標記映像
        {
          rule_priority   = 1
          description     = "刪除超過 30 天的未標記映像"
          tag_status      = "untagged"
          tag_prefix_list = []
          count_type      = "sinceImagePushed"
          count_number    = 30
        },
        # 規則 2: 限制映像總數
        {
          rule_priority   = 2
          description     = "留最新的 5 個映像"
          tag_status      = "any"
          tag_prefix_list = [] # 對於 any 類型，這個欄位可被忽略
          count_type      = "imageCountMoreThan"
          count_number    = 5
        }
      ]
      tags = {}
    },

    #=====================================================
    # Fish 服務儲存庫
    #=====================================================
    "bing-ecr-2" = {
      lifecycle_rules = [
        # 規則 1: 清理舊的未標記映像
        {
          rule_priority   = 1
          description     = "刪除超過 30 天的未標記映像"
          tag_status      = "untagged"
          tag_prefix_list = []
          count_type      = "sinceImagePushed"
          count_number    = 30
        },
        # 規則 2: 限制映像總數
        {
          rule_priority   = 2
          description     = "留最新的 5 個映像"
          tag_status      = "any"
          tag_prefix_list = []
          count_type      = "imageCountMoreThan"
          count_number    = 5
        }
      ]
      tags = {}
    },

    #=====================================================
    # FishMatch 服務儲存庫
    #=====================================================
    "bing-ecr-3" = {
      lifecycle_rules = [
        # 規則 1: 清理舊的未標記映像
        {
          rule_priority   = 1
          description     = "刪除超過 30 天的未標記映像"
          tag_status      = "untagged"
          tag_prefix_list = []
          count_type      = "sinceImagePushed"
          count_number    = 30
        },
        # 規則 2: 限制映像總數
        {
          rule_priority   = 2
          description     = "留最新的 5 個映像"
          tag_status      = "any"
          tag_prefix_list = []
          count_type      = "imageCountMoreThan"
          count_number    = 5
        }
      ]
      tags = {}
    },

    #=====================================================
    # Schedule 服務儲存庫
    #=====================================================
    "bing-ecr-4" = {
      lifecycle_rules = [
        # 規則 1: 清理舊的未標記映像
        {
          rule_priority   = 1
          description     = "刪除超過 30 天的未標記映像"
          tag_status      = "untagged"
          tag_prefix_list = []
          count_type      = "sinceImagePushed"
          count_number    = 30
        },
        # 規則 2: 限制映像總數
        {
          rule_priority   = 2
          description     = "留最新的 5 個映像"
          tag_status      = "any"
          tag_prefix_list = []
          count_type      = "imageCountMoreThan"
          count_number    = 5
        }
      ]
      tags = {}
    }
  }
}
