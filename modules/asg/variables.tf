variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
}

variable "private_subnet_ids" {
  description = "Private subnet IDs to launch instances in"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ALB target group ARN to register instances with"
  type        = string
}

variable "launch_template_id" {
  description = "EC2 launch template ID"
  type        = string
}

variable "launch_template_version" {
  description = "EC2 launch template version"
  type        = string
}
