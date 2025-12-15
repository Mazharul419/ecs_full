variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

variable "task_cpu" {
  description = "CPU units for the task"
  type        = string
}

variable "task_memory" {
  description = "Memory for the task in MB"
  type        = string
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
}