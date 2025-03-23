#!/bin/bash

# 設定固定的配置文件
TF_CONFIG_FILE="main.tf"

# 檢查輸入參數數量，不足時顯示用法提示
if [ "$#" -lt 3 ]; then
    echo "用法: $0 <USERNAME> <DATE> <REGION>"
    echo "範例: $0 john 20240323 ap-northeast-1"
    exit 1
fi

# 透過位置參數讀取變數
USERNAME="$1"
DATE="$2"
REGION="$3"
BUCKET_NAME="${USERNAME}-${DATE}-terraform-state"
TABLE_NAME="${USERNAME}-${DATE}-terraform-locks"

# 顏色定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# 錯誤處理函數
error_exit() {
    echo -e "${RED}錯誤: $1${NC}" >&2
    exit 1
}

# 確認檔案存在
if [ ! -f "$TF_CONFIG_FILE" ]; then
    error_exit "找不到檔案 $TF_CONFIG_FILE"
fi

echo -e "${YELLOW}將在 $TF_CONFIG_FILE 中更新 Terraform 後端設定...${NC}"

# 先備份原始檔案
BACKUP_FILE="${TF_CONFIG_FILE}.bak"
cp "$TF_CONFIG_FILE" "$BACKUP_FILE" || error_exit "無法建立備份檔案"
echo "已建立備份檔案: $BACKUP_FILE"

# 使用 sed 更新 bucket 值
sed -i "s/bucket[[:space:]]*=[[:space:]]*\"[^\"]*\"/bucket         = \"${BUCKET_NAME}\"/" "$TF_CONFIG_FILE" || error_exit "無法更新 bucket 值"

# 使用 sed 更新 region 值
sed -i "s/region[[:space:]]*=[[:space:]]*\"[^\"]*\"/region         = \"${REGION}\"/" "$TF_CONFIG_FILE" || error_exit "無法更新 region 值"

# 使用 sed 更新 dynamodb_table 值
sed -i "s/dynamodb_table[[:space:]]*=[[:space:]]*\"[^\"]*\"/dynamodb_table = \"${TABLE_NAME}\"/" "$TF_CONFIG_FILE" || error_exit "無法更新 dynamodb_table 值"

echo -e "${GREEN}已成功更新 Terraform 後端設定:${NC}"
echo "S3 Bucket: ${BUCKET_NAME}"
echo "DynamoDB Table: ${TABLE_NAME}"
echo "Region: ${REGION}"

# 顯示修改後的配置
echo -e "\n${YELLOW}修改後的 Terraform 後端配置:${NC}"
grep -A 5 "backend \"s3\"" "$TF_CONFIG_FILE"

echo -e "\n${GREEN}完成！${NC}"