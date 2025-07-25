#!/bin/bash

# CONFIGURATION
PROJECT_NAME="terraform-backend"
BUCKET_NAME="pv-demo-terraform-backend"
DYNAMO_TABLE="pv-demo-terraform-lock"
REGION="us-east-1"
KEY_ALIAS="alias/pv-01-demo-terraform-backend-key"
TFSTATE_KEY_PATH="global/bootstrap/terraform.tfstate"  
BACKEND_FILE="backend.tf"

export AWS_PAGER=""

echo "=== Starting Terraform Backend Bootstrap ==="

# === CREATE KMS KEY ===
echo "Creating KMS key to secure S3 encryption"
KEY_ID=$(aws kms create-key \
  --description "KMS key for Terraform backend" \
  --region "$REGION" \
  --query KeyMetadata.KeyId \
  --output text)

# Create Key alias
echo "Creating alias: $KEY_ALIAS"
aws kms create-alias \
  --alias-name "$KEY_ALIAS" \
  --target-key-id "$KEY_ID" \
  --region "$REGION"

# Obtain ARN Key
KEY_ARN=$(aws kms describe-key \
  --key-id "$KEY_ID" \
  --region "$REGION" \
  --query KeyMetadata.Arn \
  --output text)

echo "KMS Key ARN: $KEY_ARN"

# CREATE S3 BUCKET
echo "Creating s3 bucket: $BUCKET_NAME"
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  #--create-bucket-configuration LocationConstraint="$REGION" 2>/dev/null

# Enable KMS encryption
echo "Encrypting bucket with KMS"
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "'"$KEY_ARN"'"
      }
    }]
  }' \
  --region "$REGION"

# Enable versioning
echo "Enabling versioning on the bucket"
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled \
  --region "$REGION"

# CREATE DYNAMO TABLE
echo "Creating DynamoDB Table for State Locking: $DYNAMO_TABLE"
aws dynamodb create-table \
  --table-name "$DYNAMO_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION"

echo "⌛ Waiting for DynamoDB table '$DYNAMO_TABLE' to become ACTIVE..."
aws dynamodb wait table-exists --table-name "$DYNAMO_TABLE" --region "$REGION"
echo "✅ DynamoDB table is now ACTIVE."

exit 0