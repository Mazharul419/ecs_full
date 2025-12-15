variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where the VPC endpoints will be created."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the endpoints will be created."
  type        = string  
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where interface endpoints will be created."
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "List of private route table IDs where the s3 gateway endpoint will be added."
  type        = list(string)
}

variable "vpc_endpoints_security_group_id" {
  description = "The security group ID to associate with the interface VPC endpoints."
  type        = string
}