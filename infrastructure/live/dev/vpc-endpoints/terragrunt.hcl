include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("_env/common.hcl")).locals
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../modules/vpc-endpoints"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id                  = "vpc-mock"
    private_subnet_ids      = ["subnet-mock-1", "subnet-mock-2"]
    private_route_table_ids = ["rtb-mock-1", "rtb-mock-2"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "security_groups" {
  config_path = "../security-groups"

  mock_outputs = {
    vpc_endpoints_security_group_id = "sg-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  project_name                    = include.root.locals.project_name
  environment                     = local.env.environment
  aws_region                      = include.root.locals.aws_region
  vpc_id                          = dependency.vpc.outputs.vpc_id
  private_subnet_ids              = dependency.vpc.outputs.private_subnet_ids
  private_route_table_ids         = dependency.vpc.outputs.private_route_table_ids
  vpc_endpoints_security_group_id = dependency.security_groups.outputs.vpc_endpoints_security_group_id
}