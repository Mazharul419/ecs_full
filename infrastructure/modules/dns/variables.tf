variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "domain_name" {
  description = "Root domain name"
  type        = string
}

variable "subdomain" {
  description = "Subdomain to create (e.g., tm-dev)"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}