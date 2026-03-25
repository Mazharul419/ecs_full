#!/bin/bash
set -e

# Disable AWS CLI pager + Run non-interactively
export AWS_PAGER=""
export TG_NON_INTERACTIVE=true

# ============================================================
# COMPLETE BOOTSTRAP SCRIPT
# Creates: S3 (state) + OIDC + ECR
# ============================================================

PROJECT_NAME="ecs-project"
AWS_REGION="eu-west-2"
INITIAL_TAG="initial"

# Get script directory (for relative paths)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$(cd "$INFRA_DIR/.." && pwd)"

# ============================================================
# STEP 1: Checks
# ============================================================

echo "STEP 1/5: Checks"

# Check AWS CLI
echo "Checking AWS CLI..."
if ! command -v aws &> /dev/null; then
  echo "AWS CLI not installed"
  echo "Install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
  exit 1
fi
echo "AWS CLI installed: $(aws --version | cut -d' ' -f1)"

# Check Terraform
echo "Checking Terraform..."
if ! command -v terraform &> /dev/null; then
  echo "Terraform not installed"
  echo "Install: https://developer.hashicorp.com/terraform/downloads"
  exit 1
fi
echo "Terraform installed: $(terraform version | head -n1)"

# Check Terragrunt
echo "Checking Terragrunt..."
if ! command -v terragrunt &> /dev/null; then
  echo "Terragrunt not installed"
  echo "Install: https://terragrunt.gruntwork.io/docs/getting-started/install/"
  exit 1
fi
echo "Terragrunt installed: $(terragrunt --version)"

# Check Docker
echo "Checking Docker..."
if ! command -v docker &> /dev/null; then
  echo "Docker not installed"
  echo "Install: https://docs.docker.com/get-docker/"
  exit 1
fi
if ! docker info &> /dev/null; then
  echo "Docker daemon not running"
  echo "Start Docker Desktop or run: sudo systemctl start docker"
  exit 1
fi
echo "Docker installed and running"

# Check AWS credentials
echo "Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
  echo "AWS credentials not configured or expired"
  echo "Run: aws configure"
  exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
CALLER_ARN=$(aws sts get-caller-identity --query Arn --output text)
echo "AWS credentials valid"
echo "Account ID: $ACCOUNT_ID"
echo "Identity: $CALLER_ARN"

# Set + Check environment variables

echo "Setting environment variables from .env file (if exists)..."

cd "$REPO_DIR"

source .env


echo ""
echo "All pre-flight checks passed!"

# ============================================================
# STEP 2: Create S3 Bucket for Terraform State
# ============================================================

echo "STEP 2/5: Creating S3 Bucket for Terraform State"

BUCKET_NAME="${PROJECT_NAME}-terraform-state-${ACCOUNT_ID}-${AWS_REGION}"

echo "Checking if bucket exists: $BUCKET_NAME"

if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "S3 bucket already exists, skipping creation"
else
  echo "Creating S3 bucket..."
  
  # Create bucket (different command for us-east-1)

  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION"

  echo "Enabling versioning..."
  aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

  echo "Enabling encryption..."
  aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
      "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        },
        "BucketKeyEnabled": true
      }]
    }'

  echo "Blocking public access..."
  aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration '{
      "BlockPublicAcls": true,
      "IgnorePublicAcls": true,
      "BlockPublicPolicy": true,
      "RestrictPublicBuckets": true
    }'

  echo "Adding tags..."
  aws s3api put-bucket-tagging \
    --bucket "$BUCKET_NAME" \
    --tagging "TagSet=[
      {Key=Project,Value=$PROJECT_NAME},
      {Key=ManagedBy,Value=Bootstrap},
      {Key=Purpose,Value=TerraformState}
    ]"

  echo "S3 bucket created: $BUCKET_NAME"
fi

# ============================================================
# STEP 3: Deploy Github Actions OIDC role with Terraform
# ============================================================

echo "STEP 3/5: Deploying GitHub OIDC Provider and Role"

cd "$INFRA_DIR/live/global/oidc"

echo "Initializing Terraform..."
terragrunt init

echo "Applying OIDC configuration..."
terragrunt apply --auto-approve

# Get outputs
ROLE_ARN=$(terragrunt output -raw role_arn 2>/dev/null || echo "")

if [ -z "$ROLE_ARN" ]; then
  echo "Could not get role ARN from output, using constructed value"
  ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/github-actions-role"
fi

echo "OIDC provider and role created via Terraform"
echo "Role ARN: $ROLE_ARN"

# ============================================================
# STEP 4: Create ECR Repo with Terraform
# ============================================================

echo "STEP 4/5: Deploying ECR Repository with Terraform"

cd "$INFRA_DIR/live/global/ecr"

echo "Initializing Terraform..."
terragrunt init

echo "Applying ECR configuration..."
terragrunt apply --auto-approve

# Get ECR URL from Terraform output
ECR_URL=$(terragrunt output -raw repository_url 2>/dev/null)

if [ -z "$ECR_URL" ]; then
  echo "Failed to get ECR URL from Terraform output"
  ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}"
  echo "Using constructed URL: $ECR_URL"
fi

echo "ECR repository created via Terraform"
echo "ECR URL: $ECR_URL"

# ============================================================
# STEP 5: Build and Push Initial Docker Image to ECR
# ============================================================

echo "STEP 5/5: Building and Pushing Initial Docker Image"

echo "Checking for existing Docker image..."

EXISTING_IMAGE=$(docker images ${PROJECT_NAME}:${INITIAL_TAG} --format "{{.CreatedAt}}" 2>/dev/null)

if [ -n "$EXISTING_IMAGE" ]; then
  echo "Existing image found - Created at: $EXISTING_IMAGE"
  echo ""
  read -p "Do you want to push this image instead? (y/n) " confirm

  if [[ "$confirm" = "y" || "$confirm" = "Y" ]]; then
    echo "Logging into ECR..."
    aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_URL"
    echo "Pushing image..."
    docker push "${ECR_URL}:${INITIAL_TAG}"
    echo "Image pushed: ${ECR_URL}:${INITIAL_TAG}"
    echo ""
  fi

    echo "Proceeding with new Docker build..."
else
  echo "No existing image found, proceeding with Docker build..."

echo "Logging into ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_URL"

echo "Building Docker image... - this will take 50 minutes to an hour"
cd "$REPO_DIR"
docker build -t "${PROJECT_NAME}:${INITIAL_TAG}" .

echo "Tagging image..."
docker tag "${PROJECT_NAME}:${INITIAL_TAG}" "${ECR_URL}:${INITIAL_TAG}"

echo "Pushing image..."
docker push "${ECR_URL}:${INITIAL_TAG}"

echo "Image pushed: ${ECR_URL}:${INITIAL_TAG}"

fi

# ============================================================
# SUMMARY
# ============================================================

echo ""
echo ""
echo "============================================================"
echo "BOOTSTRAP COMPLETE"
echo "============================================================"
echo ""
echo "RESOURCES CREATED:"
echo ""
echo "S3 Bucket (Terraform State):"
echo "  $BUCKET_NAME"
echo ""
echo "GitHub OIDC:"
echo "  Provider: token.actions.githubusercontent.com"
echo "  Role: arn:aws:iam::${ACCOUNT_ID}:role/github-actions-role"
echo ""
echo "ECR Repository:"
echo "  $ECR_URL"
echo "  Image: ${INITIAL_TAG}"
echo ""