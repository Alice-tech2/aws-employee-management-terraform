output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.main.name
}

output "asg_arn" {
  description = "Auto Scaling Group ARN"
  value       = aws_autoscaling_group.main.arn
}

output "scale_out_policy_arn" {
  description = "Scale out policy ARN - used by CloudWatch alarm"
  value       = aws_autoscaling_policy.scale_out.arn
}

output "scale_in_policy_arn" {
  description = "Scale in policy ARN - used by CloudWatch alarm"
  value       = aws_autoscaling_policy.scale_in.arn
}
