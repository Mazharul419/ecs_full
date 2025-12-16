include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("_env/common.hcl")).locals
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../modules/security-groups"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id   = "vpc-mock"
    vpc_cidr = "10.0.0.0/16"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  project_name   = include.root.locals.project_name
  environment    = local.env.environment
  vpc_id         = dependency.vpc.outputs.vpc_id
  vpc_cidr       = dependency.vpc.outputs.vpc_cidr
  container_port = local.common.container_port
}