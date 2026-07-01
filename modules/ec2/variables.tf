variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ec2_sg_id" {
  description = "EC2 security group ID"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "db_host" {
  description = "RDS hostname"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN for DB credentials"
  type        = string
}
