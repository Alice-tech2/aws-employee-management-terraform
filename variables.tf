# -------------------------------------------
# GENERAL
# -------------------------------------------
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "Environment must be dev, stg or prod."
  }
}

variable "project_name" {
  description = "Project name used for naming all resources"
  type        = string
  default     = "devops-project"
}

# -------------------------------------------
# BACKEND
# -------------------------------------------
variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
}

# -------------------------------------------
# NETWORKING
# -------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

# -------------------------------------------
# EC2
# -------------------------------------------
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

# -------------------------------------------
# AUTO SCALING
# -------------------------------------------
variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
}

# -------------------------------------------
# RDS
# -------------------------------------------
variable "db_name" {
  description = "MySQL database name"
  type        = string
  default     = "employeedb"
}

variable "db_username" {
  description = "MySQL master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "MySQL master password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}
