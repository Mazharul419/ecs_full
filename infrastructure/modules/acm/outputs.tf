output "certificate_arn" {
  description = "ARN of the validated certificate"
  value       = aws_acm_certificate_validation.main.certificate_arn
}

output "certificate_domain" {
  description = "Domain name of the certificate"
  value       = aws_acm_certificate.main.domain_name
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.main.status
}

output "validation_record_fqdns" {
  description = "FQDNs of the validation records"
  value       = [for dvo in aws_acm_certificate.main.domain_validation_options : dvo.resource_record_name]
}