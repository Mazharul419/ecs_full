include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../modules/oidc"
}

inputs = {
  project_name = include.root.locals.project_name
  aws_region   = include.root.locals.aws_region
  account_id   = include.root.locals.account_id
  github_org   = "Mazharul419"
  github_repo  = "ecs_full"
}