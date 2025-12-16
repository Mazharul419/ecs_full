include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("_env/common.hcl")).locals
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../modules/alb"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id            = "vpc-mock"
    public_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "security_groups" {
  config_path = "../security-groups"

  mock_outputs = {
    alb_security_group_id = "sg-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "acm" {
  config_path = "../acm"

  mock_outputs = {
    certificate_arn = "arn:aws:acm:eu-west-2:123456789012:certificate/mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  project_name          = include.root.locals.project_name
  environment           = local.env.environment
  vpc_id                = dependency.vpc.outputs.vpc_id
  public_subnet_ids     = dependency.vpc.outputs.public_subnet_ids
  alb_security_group_id = dependency.security_groups.outputs.alb_security_group_id
  certificate_arn       = dependency.acm.outputs.certificate_arn
  container_port        = local.common.container_port
}