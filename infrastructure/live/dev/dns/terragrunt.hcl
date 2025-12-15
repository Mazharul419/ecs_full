include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("_env/common.hcl")).locals
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../modules/dns"
}

dependency "alb" {
  config_path = "../alb"

  mock_outputs = {
    alb_dns_name = "mock-alb.eu-west-2.elb.amazonaws.com"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  project_name       = include.root.locals.project_name
  environment        = local.env.environment
  cloudflare_zone_id = local.common.cloudflare_zone_id
  domain_name        = local.common.domain_name
  subdomain          = local.env.subdomain
  alb_dns_name       = dependency.alb.outputs.alb_dns_name
}