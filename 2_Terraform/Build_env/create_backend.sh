#!/bin/bash

# 檢查輸入參數數量，不足時顯示用法提示
if [ "$#" -lt 3 ]; then
    echo "用法: $0 <USERNAME> <DATE> <REGION>"
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

echo "開始建立 Terraform 後端基礎設施..."

# 檢查 S3 bucket 是否已存在
if aws s3 ls "s3://${BUCKET_NAME}" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "建立 S3 bucket: ${BUCKET_NAME}"
    
    # 根據區域決定建立 S3 bucket 的命令
    if [ "${REGION}" = "us-east-1" ]; then
        # us-east-1 不需要 LocationConstraint
        aws s3api create-bucket \
            --bucket "${BUCKET_NAME}" \
            --region "${REGION}" || error_exit "無法建立 S3 bucket"
    else
        # 非 us-east-1 需要指定 LocationConstraint
        aws s3api create-bucket \
            --bucket "${BUCKET_NAME}" \
            --region "${REGION}" \
            --create-bucket-configuration LocationConstraint="${REGION}" || error_exit "無法建立 S3 bucket"
    fi
    
    # 啟用版本控制
    aws s3api put-bucket-versioning \
        --bucket "${BUCKET_NAME}" \
        --versioning-configuration Status=Enabled || error_exit "無法啟用版本控制"

    # 添加/更新限制只能走 SSL 的 bucket policy
    echo "更新 S3 bucket policy 強制使用 SSL 連線..."
    SSL_POLICY='{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "ForceSSLOnly",
                "Effect": "Deny",
                "Principal": "*",
                "Action": "s3:*",
                "Resource": [
                    "arn:aws:s3:::'"${BUCKET_NAME}"'",
                    "arn:aws:s3:::'"${BUCKET_NAME}"'/*"
                ],
                "Condition": {
                    "Bool": {
                        "aws:SecureTransport": "false"
                    }
                }
            }
        ]
    }'
    
    aws s3api put-bucket-policy \
        --bucket "${BUCKET_NAME}" \
        --policy "$SSL_POLICY" || error_exit "無法更新 S3 bucket policy"

fi

# 檢查 DynamoDB table 是否已存在
if aws dynamodb describe-table --table-name "${TABLE_NAME}" 2>&1 | grep -q 'ResourceNotFoundException'; then
    echo "建立 DynamoDB table: ${TABLE_NAME}"
    # 建立 DynamoDB table 並添加標籤
    aws dynamodb create-table \
        --table-name "${TABLE_NAME}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --output text \
        --region "${REGION}" || error_exit "無法建立 DynamoDB table"
    
    # 等待 table 建立完成
    echo "等待 DynamoDB table 建立完成..."
    aws dynamodb wait table-exists \
        --table-name "${TABLE_NAME}" \
        --region "${REGION}" || error_exit "等待 DynamoDB table 建立時發生錯誤"
    
    echo -e "${GREEN}DynamoDB table 建立完成${NC}"
fi

# 建立ec2 key 
echo "建立ec2 key "
aws ec2 create-key-pair \
  --key-name "${USERNAME}-key" \
  --region "${REGION}" \
  --output text && echo -e "${GREEN}ec2 key 建立完成${NC}" || error_exit "建立EC2 Key 發生錯誤" 


echo -e "${GREEN}後端基礎設施建立完成!${NC}"
echo "S3 Bucket: ${BUCKET_NAME}"
echo "DynamoDB Table: ${TABLE_NAME}"
echo "Region: ${REGION}"
echo "EC2 key ${USERNAME}-key"

# 顯示如何在 Terraform 中使用這些資源
echo -e "\n在 Terraform 中使用這些資源的配置範例："
echo "terraform {"
echo "  backend \"s3\" {"
echo "    bucket         = \"${BUCKET_NAME}\""
echo "    key            = \"terraform.tfstate\""
echo "    region         = \"${REGION}\""
echo "    dynamodb_table = \"${TABLE_NAME}\""
echo "    encrypt        = true"
echo "  }"
echo "}"