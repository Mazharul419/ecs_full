#!/bin/bash
set -e


# Disable AWS CLI pager
export AWS_PAGER=""

# ============================================================
# COMPLETE BOOTSTRAP SCRIPT
# Creates: S3 (state) → OIDC → ECR → Dev → Prod
# ============================================================

# ============================================================
# CONFIGURATION
# ============================================================

PROJECT_NAME="ecs-project"
AWS_REGION="eu-west-2"
INITIAL_TAG="initial"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================
# HELPER FUNCTIONS
# ============================================================

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

print_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

print_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

# Get script directory (for relative paths)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$(cd "$INFRA_DIR/.." && pwd)"

# ============================================================
# STEP 1: PRE-FLIGHT CHECKS
# ============================================================

print_step "STEP 1/9: Pre-flight Checks"

# Check AWS CLI
print_substep "Checking AWS CLI..."
if ! command -v aws &> /dev/null; then
  print_error "AWS CLI not installed"
  echo "Install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
  exit 1
fi
print_success "AWS CLI installed: $(aws --version | cut -d' ' -f1)"

# Check Terraform
print_substep "Checking Terraform..."
if ! command -v terraform &> /dev/null; then
  print_error "Terraform not installed"
  echo "Install: https://developer.hashicorp.com/terraform/downloads"
  exit 1
fi
print_success "Terraform installed: $(terraform version | head -n1)"

# Check Terragrunt
print_substep "Checking Terragrunt..."
if ! command -v terragrunt &> /dev/null; then
  print_error "Terragrunt not installed"
  echo "Install: https://terragrunt.gruntwork.io/docs/getting-started/install/"
  exit 1
fi
print_success "Terragrunt installed: $(terragrunt --version)"

# Check Docker
print_substep "Checking Docker..."
if ! command -v docker &> /dev/null; then
  print_error "Docker not installed"
  echo "Install: https://docs.docker.com/get-docker/"
  exit 1
fi
if ! docker info &> /dev/null; then
  print_error "Docker daemon not running"
  echo "Start Docker Desktop or run: sudo systemctl start docker"
  exit 1
fi
print_success "Docker installed and running"

# Check jq (needed for some commands)
print_substep "Checking jq..."
if ! command -v jq &> /dev/null; then
  print_warning "jq not installed (optional but recommended)"
  echo "Install: sudo apt install jq"
else
  print_success "jq installed"
fi

# Check AWS credentials
print_substep "Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
  print_error "AWS credentials not configured or expired"
  echo "Run: aws configure"
  exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
CALLER_ARN=$(aws sts get-caller-identity --query Arn --output text)
print_success "AWS credentials valid"
print_info "Account ID: $ACCOUNT_ID"
print_info "Identity: $CALLER_ARN"

# Check environment variables
print_substep "Checking environment variables..."

if [ -z "$TF_VAR_cloudflare_api_token" ]; then
  print_error "TF_VAR_cloudflare_api_token not set"
  echo ""
  echo "Create .env file:"
  echo "  export TF_VAR_cloudflare_api_token=\"your-token\""
  echo "  export CLOUDFLARE_ZONE_ID=\"your-zone-id\""
  echo ""
  echo "Then run: source $INFRA_DIR/.env"
  exit 1
fi
print_success "TF_VAR_cloudflare_api_token is set"

if [ -z "$CLOUDFLARE_ZONE_ID" ]; then
  print_error "CLOUDFLARE_ZONE_ID not set"
  echo "Add to .env: export CLOUDFLARE_ZONE_ID=\"your-zone-id\""
  echo "Then run: source $INFRA_DIR/.env"
  exit 1
fi
print_success "CLOUDFLARE_ZONE_ID is set"

echo ""
print_success "All pre-flight checks passed!"

# ============================================================
# STEP 2: CREATE S3 BUCKET FOR TERRAFORM STATE
# ============================================================

print_step "STEP 2/9: Creating S3 Bucket for Terraform State"

BUCKET_NAME="${PROJECT_NAME}-terraform-state-${ACCOUNT_ID}-${AWS_REGION}"

print_substep "Checking if bucket exists: $BUCKET_NAME"

if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  print_success "S3 bucket already exists, skipping creation"
else
  print_substep "Creating S3 bucket..."
  
  # Create bucket (different command for us-east-1)

  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION"

  print_substep "Enabling versioning..."
  aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
  
  print_substep "Enabling encryption..."
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
  
  print_substep "Blocking public access..."
  aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration '{
      "BlockPublicAcls": true,
      "IgnorePublicAcls": true,
      "BlockPublicPolicy": true,
      "RestrictPublicBuckets": true
    }'
  
  print_substep "Adding tags..."
  aws s3api put-bucket-tagging \
    --bucket "$BUCKET_NAME" \
    --tagging "TagSet=[
      {Key=Project,Value=$PROJECT_NAME},
      {Key=ManagedBy,Value=Bootstrap},
      {Key=Purpose,Value=TerraformState}
    ]"
  
  print_success "S3 bucket created: $BUCKET_NAME"
fi

# ============================================================
# STEP 3: CREATE OIDC PROVIDER AND ROLE
# ============================================================

print_step "STEP 3/9: Creating GitHub OIDC Provider and Role"

# Check if OIDC provider exists
print_substep "Checking if OIDC provider exists..."
OIDC_PROVIDER_ARN="arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"

if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$OIDC_PROVIDER_ARN" &> /dev/null; then
  print_success "OIDC provider already exists"
else
  print_substep "Creating OIDC provider..."
  
  aws iam create-open-id-connect-provider \
    --url "https://token.actions.githubusercontent.com" \
    --client-id-list "sts.amazonaws.com" \
    --thumbprint-list "6938fd4d98bab03faadb97b34396831e3780aea1"
  
  print_success "OIDC provider created"
fi

# Check if role exists
print_substep "Checking if IAM role exists..."
ROLE_NAME="github-actions-role"

if aws iam get-role --role-name "$ROLE_NAME" &> /dev/null; then
  print_success "IAM role already exists"
else
  print_substep "Creating IAM role..."
  
  # Get GitHub org/repo from git remote (or use defaults)
  GITHUB_ORG="Mazharul419"
  GITHUB_REPO="ecs_full"
  
  # Try to get from git remote
  if git remote get-url origin &> /dev/null; then
    REMOTE_URL=$(git remote get-url origin)
    if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
      GITHUB_ORG="${BASH_REMATCH[1]}"
      GITHUB_REPO="${BASH_REMATCH[2]}"
    fi
  fi
  
  print_info "GitHub repo: $GITHUB_ORG/$GITHUB_REPO"
  
  # Create trust policy
  TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_ORG}/${GITHUB_REPO}:*"
        }
      }
    }
  ]
}
EOF
)
  
  aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document "$TRUST_POLICY" \
    --description "Role for GitHub Actions CI/CD" \
    --tags Key=Project,Value=$PROJECT_NAME Key=ManagedBy,Value=Bootstrap
  
  print_success "IAM role created"
  
  # Create permissions policy
  print_substep "Attaching permissions policy..."
  
  PERMISSIONS_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ECRAuth",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ECRPush",
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "arn:aws:ecr:${AWS_REGION}:${ACCOUNT_ID}:repository/${PROJECT_NAME}"
    },
    {
      "Sid": "ECSTaskDefinition",
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ECSService",
      "Effect": "Allow",
      "Action": [
        "ecs:UpdateService",
        "ecs:DescribeServices"
      ],
      "Resource": [
        "arn:aws:ecs:${AWS_REGION}:${ACCOUNT_ID}:service/${PROJECT_NAME}-dev-cluster/${PROJECT_NAME}-dev-service",
        "arn:aws:ecs:${AWS_REGION}:${ACCOUNT_ID}:service/${PROJECT_NAME}-prod-cluster/${PROJECT_NAME}-prod-service"
      ]
    },
    {
      "Sid": "PassRole",
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "arn:aws:iam::${ACCOUNT_ID}:role/${PROJECT_NAME}-*-ecs-execution-role"
    }
  ]
}
EOF
)
  
  aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name "github-actions-policy" \
    --policy-document "$PERMISSIONS_POLICY"
  
  print_success "Permissions policy attached"
fi

# ============================================================
# STEP 4: CREATE ECR REPOSITORY
# ============================================================

print_step "STEP 4/9: Creating ECR Repository"

print_substep "Checking if ECR repository exists..."

if aws ecr describe-repositories --repository-names "$PROJECT_NAME" --region "$AWS_REGION" &> /dev/null; then
  print_success "ECR repository already exists"
else
  print_substep "Creating ECR repository..."
  
  aws ecr create-repository \
    --repository-name "$PROJECT_NAME" \
    --region "$AWS_REGION" \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256 \
    --tags Key=Project,Value=$PROJECT_NAME Key=ManagedBy,Value=Bootstrap
  
  print_substep "Adding lifecycle policy (keep last 10 images)..."
  
  LIFECYCLE_POLICY=$(cat <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
)
  
  aws ecr put-lifecycle-policy \
    --repository-name "$PROJECT_NAME" \
    --region "$AWS_REGION" \
    --lifecycle-policy-text "$LIFECYCLE_POLICY"
  
  print_success "ECR repository created"
fi

ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}"
print_info "ECR URL: $ECR_URL"

# ============================================================
# STEP 5: BUILD AND PUSH INITIAL DOCKER IMAGE
# ============================================================

print_step "STEP 5/9: Building and Pushing Initial Docker Image"

# Check if Dockerfile exists
if [ ! -f "$REPO_DIR/app/Dockerfile" ]; then
  print_error "Dockerfile not found at $REPO_DIR/app/Dockerfile"
  exit 1
fi

print_substep "Logging into ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_URL"

print_substep "Building Docker image... - this will take minimum 30 minutes, and can go up to 1 hour depending on your specs"
cd "$REPO_DIR/app"
docker build -t "${PROJECT_NAME}:${INITIAL_TAG}" .

print_substep "Tagging image..."
docker tag "${PROJECT_NAME}:${INITIAL_TAG}" "${ECR_URL}:${INITIAL_TAG}"

print_substep "Pushing image..."
docker push "${ECR_URL}:${INITIAL_TAG}"

print_success "Image pushed: ${ECR_URL}:${INITIAL_TAG}"

# ============================================================
# STEP 6: DEPLOY DEV INFRASTRUCTURE
# ============================================================

print_step "STEP 6/9: Deploying Dev Infrastructure"

print_info "This will create: VPC, Security Groups, VPC Endpoints, ACM, ALB, ECS, DNS"
print_info "Estimated time: 10-15 minutes"
echo ""

cd "$INFRA_DIR/live/dev"

print_substep "Running terragrunt run --all apply..."
terragrunt run --all apply --non-interactive

print_success "Dev infrastructure deployed"

# ============================================================
# STEP 7: VERIFY DEV DEPLOYMENT
# ============================================================

print_step "STEP 7/9: Verifying Dev Deployment"

print_substep "Waiting 60 seconds for services to stabilize..."
sleep 60

DEV_URL="https://tm-dev.mazharulislam.dev"

print_substep "Testing $DEV_URL..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$DEV_URL" || echo "000")

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
  print_success "Dev is accessible (HTTP $HTTP_CODE): $DEV_URL"
else
  print_warning "Dev returned HTTP $HTTP_CODE - may still be starting"
  print_info "Check manually: $DEV_URL"
fi

# ============================================================
# STEP 8: DEPLOY PROD INFRASTRUCTURE
# ============================================================

print_step "STEP 8/9: Deploying Prod Infrastructure"

print_info "Estimated time: 10-15 minutes"
echo ""

cd "$INFRA_DIR/live/prod"

print_substep "Running terragrunt run --all apply..."
terragrunt run --all apply --non-interactive

print_success "Prod infrastructure deployed"

# ============================================================
# STEP 9: VERIFY PROD DEPLOYMENT
# ============================================================

print_step "STEP 9/9: Verifying Prod Deployment"

print_substep "Waiting 60 seconds for services to stabilize..."
sleep 60

PROD_URL="https://tm.mazharulislam.dev"

print_substep "Testing $PROD_URL..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$PROD_URL" || echo "000")

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
  print_success "Prod is accessible (HTTP $HTTP_CODE): $PROD_URL"
else
  print_warning "Prod returned HTTP $HTTP_CODE - may still be starting"
  print_info "Check manually: $PROD_URL"
fi

# ============================================================
# SUMMARY
# ============================================================

echo ""
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}🎉 BOOTSTRAP COMPLETE!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo -e "${BLUE}RESOURCES CREATED:${NC}"
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
echo "  Initial image: :${INITIAL_TAG}"
echo ""
echo "Dev Environment:"
echo "  URL: $DEV_URL"
echo "  Cluster: ${PROJECT_NAME}-dev-cluster"
echo ""
echo "Prod Environment:"
echo "  URL: $PROD_URL"
echo "  Cluster: ${PROJECT_NAME}-prod-cluster"
echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${YELLOW}MANUAL STEPS REQUIRED:${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo "1. Add GitHub Secret:"
echo "   Go to: GitHub → Repo → Settings → Secrets → Actions"
echo "   Add new secret:"
echo "     Name:  AWS_ACCOUNT_ID"
echo "     Value: $ACCOUNT_ID"
echo ""
echo "2. Create GitHub Environments:"
echo "   Go to: GitHub → Repo → Settings → Environments"
echo "   Create: dev (no protection rules)"
echo "   Create: prod (add yourself as required reviewer)"
echo ""
echo "3. Push code to trigger CI/CD:"
echo "   git add ."
echo "   git commit -m \"Bootstrap complete\""
echo "   git push origin main"
echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}USEFUL COMMANDS:${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo "View dev logs:"
echo "  aws logs tail /ecs/${PROJECT_NAME}-dev --follow"
echo ""
echo "View prod logs:"
echo "  aws logs tail /ecs/${PROJECT_NAME}-prod --follow"
echo ""
echo "List ECR images:"
echo "  aws ecr list-images --repository-name ${PROJECT_NAME}"
echo ""
echo "Check ECS service status:"
echo "  aws ecs describe-services --cluster ${PROJECT_NAME}-dev-cluster --services ${PROJECT_NAME}-dev-service --query 'services[0].runningCount'"
echo ""
echo -e "${GREEN}============================================================${NC}"