output "launch_template_id" {
  description = "Launch template ID - used by ASG to launch instances"
  value       = aws_launch_template.main.id
}

output "launch_template_version" {
  description = "Latest launch template version"
  value       = aws_launch_template.main.latest_version
}
