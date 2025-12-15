variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "domain_name" {
  description = "Root domain name"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for the certificate"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for DNS validation"
  type        = string
}