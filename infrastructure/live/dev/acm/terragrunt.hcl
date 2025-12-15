include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("_env/common.hcl")).locals
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../modules/acm"
}

inputs = {
  project_name = include.root.locals.project_name
  environment  = local.env.environment
  aws_region   = include.root.locals.aws_region
  domain_name  = include.root.locals.domain_name
  subdomain    = local.env.subdomain
  cloudflare_zone_id = local.common.cloudflare_zone_id
}