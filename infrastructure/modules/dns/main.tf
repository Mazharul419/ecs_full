resource "cloudflare_dns_record" "app" {
  zone_id = var.cloudflare_zone_id
  name    = var.subdomain
  type    = "CNAME"
  content = var.alb_dns_name
  ttl     = 300
  proxied = false

  comment = "ALB DNS record for ${var.project_name}-${var.environment}"
}