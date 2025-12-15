output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}