output "alb_dns_name" {
  description = "ALB DNS name - use this to access the application"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "Target group ARN - used by ASG to register instances"
  value       = aws_lb_target_group.main.arn
}
