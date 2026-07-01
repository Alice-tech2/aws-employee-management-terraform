variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "asg_name" {
  description = "Auto Scaling Group name"
  type        = string
}

variable "scale_out_policy_arn" {
  description = "ASG scale out policy ARN"
  type        = string
}

variable "scale_in_policy_arn" {
  description = "ASG scale in policy ARN"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}
