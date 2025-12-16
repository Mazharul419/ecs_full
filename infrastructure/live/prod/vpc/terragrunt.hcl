include "root" {
  path = find_in_parent_folders()
  expose = true
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("_env/common.hcl")).locals
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  project_name         = include.root.locals.project_name
  environment          = local.env.environment
  aws_region           = include.root.locals.aws_region
  vpc_cidr             = local.env.vpc_cidr
  public_subnet_cidrs  = local.env.public_subnet_cidrs
  private_subnet_cidrs = local.env.private_subnet_cidrs
}