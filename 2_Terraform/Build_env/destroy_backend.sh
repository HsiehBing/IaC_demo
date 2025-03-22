#!/bin/bash

# 檢查輸入參數數量，不足時顯示用法提示
if [ "$#" -lt 3 ]; then
    echo "用法: $0 <USERNAME> <DATE> <REGION>"
    echo "範例: $0 user1 20250322 us-west-2"
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
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 錯誤處理函數
error_exit() {
    echo -e "${RED}錯誤: $1${NC}" >&2
    exit 1
}

# 確認 AWS CLI 是否已安裝
if ! command -v aws &> /dev/null; then
    error_exit "找不到 AWS CLI，請先安裝"
fi

# 安全確認
echo -e "${YELLOW}警告: 此操作將刪除以下資源:${NC}"
echo "- S3 Bucket: ${BUCKET_NAME} (包含所有內容)"
echo "- DynamoDB Table: ${TABLE_NAME}"
echo "- 區域: ${REGION}"
echo
read -p "確定要繼續刪除這些資源嗎? (y/n): " CONFIRM

if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "操作已取消。"
    exit 0
fi

echo "開始清理 Terraform 後端基礎設施..."

# 檢查 S3 Bucket 是否存在
echo "檢查 S3 Bucket: ${BUCKET_NAME} 是否存在..."
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    echo "S3 Bucket ${BUCKET_NAME} 存在，開始清理..."
    
    # 移除 Bucket Policy (可能會阻止刪除)
    echo "移除 Bucket Policy..."
    aws s3api delete-bucket-policy --bucket "${BUCKET_NAME}" || echo "無 Bucket Policy 或移除失敗"
    
    # 先禁用版本控制以防止新增更多版本
    echo "禁用版本控制..."
    aws s3api put-bucket-versioning \
        --bucket "${BUCKET_NAME}" \
        --versioning-configuration Status=Suspended || echo "禁用版本控制失敗"
    
    # 移除 Bucket 加密設定 (有時也會阻礙刪除)
    echo "移除 Bucket 加密設定..."
    aws s3api delete-bucket-encryption --bucket "${BUCKET_NAME}" 2>/dev/null || echo "無加密設定或移除失敗"
    
    # 使用 AWS CLI S3 命令先清空 Bucket (包括刪除標記)
    echo "清空 Bucket 中的所有物件 (第一步，使用 s3 rm)..."
    aws s3 rm "s3://${BUCKET_NAME}" --recursive || echo "使用 s3 rm 清空失敗或 Bucket 已清空"
    
    # 使用 s3api 精確刪除所有版本和刪除標記
    echo "清理所有物件版本和刪除標記 (第二步)..."
    
    # 處理所有物件版本
    echo "處理物件版本..."
    aws s3api list-object-versions \
        --bucket "${BUCKET_NAME}" \
        --query "Versions[].{Key:Key,VersionId:VersionId}" \
        --output json 2>/dev/null | \
    jq -r '.[] | "\(.Key),\(.VersionId)"' | \
    while IFS="," read -r KEY VERSION_ID; do
        if [ -n "$KEY" ] && [ -n "$VERSION_ID" ]; then
            echo "  刪除物件: $KEY (版本: $VERSION_ID)"
            aws s3api delete-object \
                --bucket "${BUCKET_NAME}" \
                --key "$KEY" \
                --version-id "$VERSION_ID" || echo "  無法刪除物件 $KEY 版本 $VERSION_ID"
        fi
    done
    
    # 處理所有刪除標記
    echo "處理刪除標記..."
    aws s3api list-object-versions \
        --bucket "${BUCKET_NAME}" \
        --query "DeleteMarkers[].{Key:Key,VersionId:VersionId}" \
        --output json 2>/dev/null | \
    jq -r '.[] | "\(.Key),\(.VersionId)"' | \
    while IFS="," read -r KEY VERSION_ID; do
        if [ -n "$KEY" ] && [ -n "$VERSION_ID" ]; then
            echo "  刪除標記: $KEY (版本: $VERSION_ID)"
            aws s3api delete-object \
                --bucket "${BUCKET_NAME}" \
                --key "$KEY" \
                --version-id "$VERSION_ID" || echo "  無法刪除標記 $KEY 版本 $VERSION_ID"
        fi
    done
    
    # 如果 jq 未安裝，使用替代方法
    if ! command -v jq &> /dev/null; then
        echo "jq 命令未安裝，使用替代方法清理..."
        # 使用 s3 rm 加上 --include 參數，這個方法通常可以清空大多數 bucket 內容
        aws s3 rm "s3://${BUCKET_NAME}" --recursive --include "*"
    fi
    
    # 最後一次確認 Bucket 是否為空
    echo "最後確認 Bucket 是否為空..."
    if aws s3api list-objects-v2 --bucket "${BUCKET_NAME}" --query "Contents[].Key" --output text 2>/dev/null | grep -q .; then
        echo -e "${YELLOW}警告: Bucket 似乎仍然不為空，嘗試強制刪除...${NC}"
    else
        echo "Bucket 已清空，準備刪除..."
    fi
    
    # 刪除 Bucket
    echo "正在刪除 S3 Bucket..."
    if aws s3api delete-bucket --bucket "${BUCKET_NAME}" --region "${REGION}"; then
        echo -e "${GREEN}成功刪除 S3 Bucket: ${BUCKET_NAME}${NC}"
    else
        echo -e "${RED}無法刪除 S3 Bucket，請參考以下替代方法:${NC}"
        echo "1. 登入 AWS 管理主控台手動刪除"
        echo "2. 嘗試使用以下命令強制刪除:"
        echo "   aws s3 rb s3://${BUCKET_NAME} --force --region ${REGION}"
    fi
else
    echo -e "${YELLOW}S3 Bucket ${BUCKET_NAME} 不存在，跳過刪除步驟${NC}"
fi

# 2. 刪除 DynamoDB Table
echo "檢查 DynamoDB Table: ${TABLE_NAME} 是否存在..."
if aws dynamodb describe-table --table-name "${TABLE_NAME}" --region "${REGION}" &>/dev/null; then
    echo "正在刪除 DynamoDB Table: ${TABLE_NAME}..."
    aws dynamodb delete-table \
        --table-name "${TABLE_NAME}" \
        --region "${REGION}" \
        --output text && echo -e "${GREEN}DynamoDB Table 已成功刪除${NC}" || echo -e "${YELLOW}警告: 無法刪除 DynamoDB Table，可能需要手動檢查${NC}"
    
    # 等待 table 刪除完成
    echo "等待 DynamoDB Table 刪除完成..."
    aws dynamodb wait table-not-exists \
        --table-name "${TABLE_NAME}" \
        --region "${REGION}" || echo -e "${YELLOW}警告: 等待 DynamoDB Table 刪除時出現錯誤${NC}"
else
    echo -e "${YELLOW}DynamoDB Table ${TABLE_NAME} 不存在，跳過刪除步驟${NC}"
fi

echo -e "\n${GREEN}清理操作已完成${NC}"
echo "如果有任何資源無法自動刪除，請登入 AWS 管理主控台手動檢查和刪除。"