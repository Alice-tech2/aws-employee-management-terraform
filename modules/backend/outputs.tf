output "state_bucket_name" {
  description = "S3 state bucket name"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "S3 state bucket ARN"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "DynamoDB lock table name"
  value       = aws_dynamodb_table.terraform_lock.name
}
