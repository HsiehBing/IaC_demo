# Terraform 結構示範專案

本專案展示了一個模組化 Terraform 架構，用於管理 AWS 資源，特別是針對 Lake Formation 權限設定的最佳實踐。該專案採用了目錄分層結構，將環境設定與可重用模組分離，提供了一個可擴展的基礎設施即代碼 (IaC) 解決方案。

## 專案結構

```
Lab5_structure_demo/
├── env/                    # 環境特定配置
│   ├── prod/               # 生產環境設定
│   ├── uat/                # 用戶驗收測試環境設定
│   └── ut/                 # 單元測試環境設定（已初始化）
│       ├── main.tf         # 主配置文件
│       ├── terraform.tfvars # 環境變數值
│       └── *.tf            # 其他配置文件
│
└── modules/                # 可重用的模組
    ├── lakeformation/      # Lake Formation 權限管理模組
    │   ├── local.tf        # 本地變數定義
    │   ├── main.tf         # 主要資源定義
    │   └── vairable.tf     # 輸入變數定義
    │
    └── vpc/                # VPC 網路模組
        ├── main.tf         # 主要資源定義
        ├── output.tf       # 輸出變數
        └── variable.tf     # 輸入變數定義
```

## Lake Formation 權限管理模組

### 設計概念

Lake Formation 模組專為管理不同資源類型（資料庫和表格）的不同權限級別而設計。關鍵特點：

1. **權限類型映射**：使用映射結構從權限類型到資源權限的對應關係
2. **資源類型分離**：為資料庫和表格分別設定權限
3. **擴展性設計**：易於新增更多權限類型，無需修改核心邏輯
4. **統一邏輯**：使用單一資源定義處理所有權限組合

### 權限類型定義

目前系統支援以下權限類型：

- **Type 1（基本權限）**：
  - 資料庫：`DESCRIBE`
  - 表格：`SELECT`

- **Type 2（進階權限）**：
  - 資料庫：`DESCRIBE`, `CREATE_TABLE`, `ALTER`, `DROP`
  - 表格：`SELECT`, `INSERT`, `DESCRIBE`

- **Type 3（示範未來擴展）**：
  - 資料庫：`DESCRIBE`, `CREATE_TABLE`
  - 表格：`SELECT`, `INSERT`, `DELETE`, `DESCRIBE`

### 使用方法

在環境配置文件（如 `env/ut/terraform.tfvars`）中，使用以下結構定義權限配置：

```hcl
permission_configs = [
  {
    principal_type  = "role"                       # "role" 或 "user"
    principal_name  = "Role-Name"                  # 角色或使用者名稱
    permission_type = 1                            # 權限類型（1 為基本權限，2 為進階權限）
    tag_expressions = [                            # LF Tag 表達式
      {
        key    = "Team"
        values = ["Sales"]
      },
      {
        key    = "Environment"
        values = ["Dev", "Production"]
      }
    ]
  }
]
```

系統會自動為每個定義的組合生成相應的資料庫和表格權限。

## 設計特點與優勢

1. **模組化架構**：將可重用邏輯封裝在模組中，便於維護和重用
2. **環境分離**：不同環境的配置分開管理，減少錯誤風險
3. **動態資源生成**：使用 Terraform 的 `for_each` 和 `flatten` 動態創建資源
4. **易於擴展**：只需修改 `local.permissions_map` 即可新增更多權限類型
5. **靈活的權限管理**：可以針對不同資源類型分別定義權限集合

## 已初始化環境

本專案包含一個已初始化的 UT（單元測試）環境，其中包含兩個權限配置示例：

1. 角色 `bing-ec2-admin` 設定為 Type 1（基本權限）
2. 使用者 `evatest` 設定為 Type 2（進階權限）

每個配置都使用 LF Tag 表達式，基於 `Team` 和 `Environment` 標籤分配資源。

## 設定步驟

1. 導航到所需的環境目錄：
   ```bash
   cd env/ut/
   ```

2. 初始化 Terraform：
   ```bash
   terraform init
   ```

3. 檢視計劃變更：
   ```bash
   terraform plan
   ```

4. 應用變更：
   ```bash
   terraform apply
   ```

## 進一步擴展

本架構可輕易擴展以支援：
- 更多權限類型
- 其他 Lake Formation 功能
- 額外的 AWS 服務和資源
- 更複雜的標籤表達式和條件

要新增新的權限類型，只需在 `modules/lakeformation/local.tf` 中的 `permissions_map` 中定義它們。
