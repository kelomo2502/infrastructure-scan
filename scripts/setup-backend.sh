#!/bin/bash

# Backend Setup Script for Terraform State
set -e

PROJECT_NAME="luralite"
ENVIRONMENT="staging"
REGION="us-east-1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Setting up Terraform backend for ${PROJECT_NAME}-${ENVIRONMENT}...${NC}"

# S3 Bucket for Terraform State
S3_BUCKET="${PROJECT_NAME}-tfstate-${ENVIRONMENT}"
echo -e "${YELLOW}Creating S3 bucket: ${S3_BUCKET}${NC}"

if aws s3 ls "s3://${S3_BUCKET}" 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3 mb "s3://${S3_BUCKET}" --region "${REGION}"
    echo -e "${GREEN}✓ S3 bucket created: ${S3_BUCKET}${NC}"
else
    echo -e "${YELLOW}✓ S3 bucket already exists: ${S3_BUCKET}${NC}"
fi

# Enable versioning on the bucket
aws s3api put-bucket-versioning \
    --bucket "${S3_BUCKET}" \
    --versioning-configuration Status=Enabled

# Enable bucket encryption
aws s3api put-bucket-encryption \
    --bucket "${S3_BUCKET}" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

echo -e "${GREEN}✓ S3 bucket versioning and encryption enabled${NC}"

# DynamoDB Table for State Locking
DYNAMODB_TABLE="${PROJECT_NAME}-tfstate-lock-${ENVIRONMENT}"
echo -e "${YELLOW}Creating DynamoDB table: ${DYNAMODB_TABLE}${NC}"

if aws dynamodb describe-table --table-name "${DYNAMODB_TABLE}" 2>&1 | grep -q 'ResourceNotFoundException'; then
    aws dynamodb create-table \
        --table-name "${DYNAMODB_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "${REGION}"
    
    # Wait for table to be active
    aws dynamodb wait table-exists --table-name "${DYNAMODB_TABLE}"
    echo -e "${GREEN}✓ DynamoDB table created: ${DYNAMODB_TABLE}${NC}"
else
    echo -e "${YELLOW}✓ DynamoDB table already exists: ${DYNAMODB_TABLE}${NC}"
fi

echo -e "${GREEN}✓ Terraform backend setup completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Run: chmod +x scripts/setup-backend.sh"
echo "2. Run: ./scripts/setup-backend.sh"
echo "3. Run: cd environments/staging && terraform init"