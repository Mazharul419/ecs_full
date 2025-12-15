locals {
  environment   = "prod"
  subdomain     = "tm"
  desired_count = 2          # Two tasks (redundancy)

  # Network (different CIDR)
  vpc_cidr             = "10.1.0.0/16"
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]

  # ECS (more resources)
  task_cpu    = "512"
  task_memory = "1024"
}