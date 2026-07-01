# -------------------------------------------
# CLOUDWATCH ALARM - HIGH CPU (Scale Out)
# When average CPU across all instances goes
# above 70% for 2 consecutive 120s periods,
# trigger the scale out policy to add an instance
# -------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale out when CPU exceeds 70%"
  alarm_actions       = [var.scale_out_policy_arn]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cpu-high"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -------------------------------------------
# CLOUDWATCH ALARM - LOW CPU (Scale In)
# When average CPU drops below 20% for 2
# consecutive 120s periods, trigger the
# scale in policy to remove an instance
# -------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Scale in when CPU drops below 20%"
  alarm_actions       = [var.scale_in_policy_arn]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cpu-low"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -------------------------------------------
# CLOUDWATCH DASHBOARD
# A single pane of glass to monitor
# CPU, ALB requests and healthy host count
# -------------------------------------------
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title   = "EC2 CPU Utilization"
          region  = var.region
          period  = 300
          stat    = "Average"
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title   = "ALB Request Count"
          region  = var.region
          period  = 300
          stat    = "Sum"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title   = "ALB Healthy Host Count"
          region  = var.region
          period  = 300
          stat    = "Average"
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", var.alb_arn_suffix]
          ]
        }
      }
    ]
  })
}
