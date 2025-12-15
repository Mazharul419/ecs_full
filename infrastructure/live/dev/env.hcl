locals {
  environment   = "dev"
  subdomain     = "tm-dev"
  desired_count = 1          # Single task (save money)

  # Network
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

  # ECS
  task_cpu    = "256" # 0.25 vCPU
  task_memory = "512" # 512 MB RAM
}