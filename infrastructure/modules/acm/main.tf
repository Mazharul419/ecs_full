resource "aws_acm_certificate" "main" {
  domain_name       = "${var.subdomain}.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    Name        = "${var.project_name}-${var.environment}-acm-cert"
  }
}

resource "cloudflare_dns_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = var.cloudflare_zone_id
  name    = trimsuffix(each.value.name, ".${var.domain_name}.")
  type    = each.value.type
  content = trimsuffix(each.value.value, ".")
  ttl     = 300
  proxied = false

  comment = "ACM validation for ${var.project_name}-${var.environment}"
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for dvo in aws_acm_certificate.main.domain_validation_options : dvo.resource_record_name]

  depends_on = [cloudflare_dns_record.cert_validation]

  timeouts {
    create = "10m"  # Timeout to wait for DNS propogation
  }
}