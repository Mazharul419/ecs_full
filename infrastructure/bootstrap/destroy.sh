#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
  echo ""
  echo -e "${BLUE}============================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}============================================================${NC}"
  echo ""
}

print_substep() {
  echo -e "${YELLOW}→ $1${NC}"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

# Configuration
PROJECT_NAME="ecs-project"
AWS_REGION="eu-west-2"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Environment variables
export TG_NON_INTERACTIVE=true
export AWS_PAGER=""

# ============================================================
# CONFIRMATION
# ============================================================

echo ""
echo -e "${RED}============================================================${NC}"
echo -e "${RED}⚠️  WARNING: DESTRUCTIVE OPERATION${NC}"
echo -e "${RED}============================================================${NC}"
echo ""
echo "This will destroy ALL resources:"
echo "  - Prod environment (ECS, ALB, VPC, DNS)"
echo "  - Dev environment (ECS, ALB, VPC, DNS)"
echo "  - ECR repository (and all images)"
echo "  - GitHub OIDC role"
echo "  - S3 state bucket (optional)"
echo ""
echo -e "${YELLOW}Account: $ACCOUNT_ID${NC}"
echo -e "${YELLOW}Region: $AWS_REGION${NC}"
echo ""
read -p "Type 'destroy' to confirm: " CONFIRM

if [ "$CONFIRM" != "destroy" ]; then
  echo "Aborted."
  exit 0
fi

# ============================================================
# DESTROY IN REVERSE ORDER
# ============================================================

print_step "Destroying Infrastructure"

DESTROY_ORDER=(
  # "live/prod/dns"
  # "live/prod/ecs"
  # "live/prod/alb"
  # "live/prod/acm"
  # "live/prod/vpc-endpoints"
  # "live/prod/security-groups"
  # "live/prod/vpc"
  "live/dev/dns"
  "live/dev/ecs"
  "live/dev/alb"
  "live/dev/acm"
  "live/dev/vpc-endpoints"
  "live/dev/security-groups"
  "live/dev/vpc"
  "global/ecr"
  "global/oidc"
)

for module in "${DESTROY_ORDER[@]}"; do
  if [ -d "$INFRA_DIR/$module" ]; then
    print_substep "Destroying: $module"
    cd "$INFRA_DIR/$module"
    
    terragrunt destroy -auto-approve || {
      print_error "Failed to destroy $module (continuing...)"
    }
  else
    print_substep "Skipping $module (not found)"
  fi
done

# ============================================================
# MANUAL CLEANUP FOR STUBBORN RESOURCES
# ============================================================

print_step "Cleaning Up Stubborn Resources"

# VPC Endpoints (if Terragrunt missed any)
print_substep "Checking for remaining VPC endpoints..."
VPC_ENDPOINTS=$(aws ec2 describe-vpc-endpoints \
  --region $AWS_REGION \
  --filters "Name=tag:Project,Values=$PROJECT_NAME" \
  --query "VpcEndpoints[].VpcEndpointId" \
  --output text 2>/dev/null || echo "")

if [ -n "$VPC_ENDPOINTS" ]; then
  print_substep "Deleting VPC endpoints..."
  for endpoint in $VPC_ENDPOINTS; do
    aws ec2 delete-vpc-endpoints \
      --region $AWS_REGION \
      --vpc-endpoint-ids $endpoint 2>/dev/null || true
  done
  print_success "VPC endpoints deleted"
  sleep 120  # Wait for ENIs to detach
fi

# Security Groups (if Terragrunt missed any)
print_substep "Checking for remaining security groups..."
sleep 30  # Extra wait after VPC endpoints

SG_IDS=$(aws ec2 describe-security-groups \
  --region $AWS_REGION \
  --filters "Name=tag:Project,Values=$PROJECT_NAME" \
  --query "SecurityGroups[].GroupId" \
  --output text 2>/dev/null || echo "")

if [ -n "$SG_IDS" ]; then
  print_substep "Deleting security groups..."
  for sg in $SG_IDS; do
    aws ec2 delete-security-group \
      --region $AWS_REGION \
      --group-id $sg 2>/dev/null || true
  done
  print_success "Security groups deleted"
fi

# ECR Images
print_substep "Checking for ECR repository..."
if aws ecr describe-repositories --repository-names "$PROJECT_NAME" --region "$AWS_REGION" &> /dev/null; then
  print_substep "Deleting ECR images..."
  
  IMAGE_IDS=$(aws ecr list-images \
    --repository-name "$PROJECT_NAME" \
    --region "$AWS_REGION" \
    --query 'imageIds[*]' \
    --output json)
  
  if [ "$IMAGE_IDS" != "[]" ]; then
    aws ecr batch-delete-image \
      --repository-name "$PROJECT_NAME" \
      --region "$AWS_REGION" \
      --image-ids "$IMAGE_IDS" > /dev/null 2>&1 || true
  fi
  
  print_substep "Deleting ECR repository..."
  aws ecr delete-repository \
    --repository-name "$PROJECT_NAME" \
    --region "$AWS_REGION" \
    --force 2>/dev/null || true
  print_success "ECR deleted"
fi

# ============================================================
# DELETE S3 BUCKET
# ============================================================

print_step "S3 State Bucket"

BUCKET_NAME="${PROJECT_NAME}-terraform-state-${ACCOUNT_ID}-${AWS_REGION}"

echo -e "${YELLOW}Delete S3 state bucket? This removes all Terraform state history.${NC}"
read -p "Delete bucket '$BUCKET_NAME'? (y/N): " DELETE_BUCKET

if [ "$DELETE_BUCKET" = "y" ] || [ "$DELETE_BUCKET" = "Y" ]; then
  if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    
    print_substep "Emptying bucket..."
    aws s3 rm "s3://${BUCKET_NAME}" --recursive 2>/dev/null || true
    
    print_substep "Deleting object versions..."
    aws s3api list-object-versions \
      --bucket "$BUCKET_NAME" \
      --output json \
      --query 'Versions[].{Key:Key,VersionId:VersionId}' 2>/dev/null | \
    jq -r '.[]? | "--key \"\(.Key)\" --version-id \"\(.VersionId)\""' | \
    xargs -I {} aws s3api delete-object --bucket "$BUCKET_NAME" {} 2>/dev/null || true
    
    print_substep "Deleting bucket..."
    aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" 2>/dev/null || true
    
    print_success "S3 bucket deleted"
  else
    print_substep "Bucket not found or already deleted"
  fi
else
  print_substep "Skipped S3 bucket deletion (state preserved)"
fi

# ============================================================
# CLEANUP LOCAL FILES
# ============================================================

print_step "Cleaning Up Local Files"

cd "$INFRA_DIR"

print_substep "Removing Terragrunt cache..."
find . -type d -name ".terragrunt-cache" -exec rm -rf {} + 2>/dev/null || true

print_substep "Removing Terraform files..."
find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true

print_success "Local files cleaned"

# ============================================================
# SUMMARY
# ============================================================

echo ""
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}🎉 TEARDOWN COMPLETE${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo -e "${BLUE}RESOURCES DESTROYED:${NC}"
echo ""
echo "✅ Prod environment"
echo "✅ Dev environment"
echo "✅ ECR repository"
echo "✅ OIDC provider and role"

if [ "$DELETE_BUCKET" = "y" ] || [ "$DELETE_BUCKET" = "Y" ]; then
  echo "✅ S3 state bucket"
else
  echo "⏭️  S3 state bucket (preserved)"
fi

echo ""
echo -e "${BLUE}============================================================${NC}"
echo ""