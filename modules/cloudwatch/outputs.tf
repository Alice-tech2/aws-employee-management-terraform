output "cpu_high_alarm_arn" {
  description = "CPU high alarm ARN"
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "cpu_low_alarm_arn" {
  description = "CPU low alarm ARN"
  value       = aws_cloudwatch_metric_alarm.cpu_low.arn
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}
