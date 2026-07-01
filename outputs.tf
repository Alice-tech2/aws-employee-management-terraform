# -------------------------------------------
# BACKEND OUTPUTS
# -------------------------------------------
output "state_bucket_name" {
  description = "S3 state bucket name"
  value       = module.backend.state_bucket_name
}

output "dynamodb_table_name" {
  description = "DynamoDB lock table name"
  value       = module.backend.dynamodb_table_name
}

# -------------------------------------------
# VPC OUTPUTS
# -------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# -------------------------------------------
# ALB OUTPUTS
# -------------------------------------------
output "alb_dns_name" {
  description = "ALB DNS name - open this in your browser to access the app"
  value       = module.alb.alb_dns_name
}

# -------------------------------------------
# ASG OUTPUTS
# -------------------------------------------
output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.asg.asg_name
}

# -------------------------------------------
# CLOUDWATCH OUTPUTS
# -------------------------------------------
output "cloudwatch_dashboard" {
  description = "CloudWatch dashboard name"
  value       = module.cloudwatch.dashboard_name
}

# -------------------------------------------
# RDS OUTPUTS
# -------------------------------------------
output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.rds.db_endpoint
}

output "db_secret_arn" {
  description = "Secrets Manager ARN for DB credentials"
  value       = module.rds.db_secret_arn
  sensitive   = true
}
