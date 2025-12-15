output "fqdn" {
  description = "Fully qualified domain name"
  value       = "${var.subdomain}.${var.domain_name}"
}

output "record_id" {
  description = "Cloudflare record ID"
  value       = cloudflare_dns_record.app.id
}

output "app_url" {
  value = "https://${var.subdomain}.${var.domain_name}"
}