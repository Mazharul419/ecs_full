include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../modules/ecr"
}

inputs = {
  project_name    = include.root.locals.project_name
  environment     = "global"
  repository_name = include.root.locals.project_name
}