include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("_env/common.hcl")).locals
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../modules/ecs"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    private_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "security_groups" {
  config_path = "../security-groups"

  mock_outputs = {
    ecs_security_group_id = "ecs-sg-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "alb" {
  config_path = "../alb"

  mock_outputs = {
    target_group_arn = "arn:aws:elasticloadbalancing:eu-west-2:123456789012:targetgroup/mock/mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "ecr" {
  config_path = "../../global/ecr"

  mock_outputs = {
    repository_url = "123456789012.dkr.ecr.eu-west-2.amazonaws.com/ecs-project"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "vpc_endpoints" {
  config_path  = "../vpc-endpoints"
  skip_outputs = true
}

inputs = {
  project_name          = include.root.locals.project_name
  environment           = local.env.environment
  aws_region            = include.root.locals.aws_region
  private_subnet_ids    = dependency.vpc.outputs.private_subnet_ids
  ecs_security_group_id = dependency.security_groups.outputs.ecs_security_group_id
  target_group_arn      = dependency.alb.outputs.target_group_arn
  container_image       = "${dependency.ecr.outputs.repository_url}:latest"
  container_port        = local.common.container_port
  task_cpu              = local.env.task_cpu
  task_memory           = local.env.task_memory
  desired_count         = local.env.desired_count
}