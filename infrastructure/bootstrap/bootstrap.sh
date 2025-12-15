#!/bin/bash

# ============================================
# Create S3 Bucket for Terraform State
# ============================================

set -e  # Exit on any error

# Configuration
PROJECT_NAME="ecs-project"
REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Bucket name: project-terraform-state-accountid-region
# This guarantees uniqueness since account ID is unique to you
BUCKET_NAME="${PROJECT_NAME}-terraform-state-${ACCOUNT_ID}-${REGION}"

# Check if region is set
if [ -z "$REGION" ]; then
  echo "❌ AWS region not configured. Run: aws configure"
  exit 1
fi

echo "🚀 Creating S3 bucket: $BUCKET_NAME"
echo "   Region: $REGION"
echo "   Account: $ACCOUNT_ID"
echo ""

# Create bucket

  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"

echo "✅ Bucket created"

# Enable versioning
echo "🔄 Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

echo "✅ Versioning enabled"

# Block public access
echo "🔒 Blocking public access..."
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "✅ Public access blocked"

# Verify
echo ""
echo "=========================================="
echo "✅ Bucket ready!"
echo "=========================================="
echo ""
echo "Bucket name: $BUCKET_NAME"
echo ""
echo "Update your infrastructure/terragrunt.hcl:"
echo ""
echo '  remote_state {'
echo '    backend = "s3"'
echo '    config = {'
echo "      bucket       = \"$BUCKET_NAME\""
echo "      region       = \"$REGION\""
echo '      key          = "${path_relative_to_include()}/terraform.tfstate"'
echo '      encrypt      = true'
echo '      use_lockfile = true'
echo '    }'
echo '  }'