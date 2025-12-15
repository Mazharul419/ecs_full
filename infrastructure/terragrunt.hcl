### Contains ALL provider/backend configuration for Terragrunt and Terraform ###

locals {
  project_name = "ecs-project"
  aws_region   = "eu-west-2"
  domain_name  = "mazharulislam.dev"
  account_id   = get_aws_account_id()
  bucket_name  = "${local.project_name}-terraform-state-${local.account_id}-${local.aws_region}"
  environment = element(split("/", path_relative_to_include()), 1)
}

remote_state {
  backend = "s3"
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  
  config = {
    bucket       = local.bucket_name
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = local.aws_region
    encrypt      = true
    use_lockfile = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  
  contents = <<EOF
terraform {
  required_version = "~> 1.14" # Allows 1.14.0, 1.14.1 etc. but not 1.15 - no major/minor suprises
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    cloudflare = {
  source  = "cloudflare/cloudflare"
  version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = {
    Project     = "${local.project_name}"
    Environment = "${local.environment}"
    ManagedBy   = "Terragrunt"
    Repository  = "github.com/Mazharul419/ecs_full"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

EOF
}