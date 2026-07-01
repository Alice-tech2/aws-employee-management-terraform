# -------------------------------------------
# AUTO SCALING GROUP
# Automatically manages the number of EC2
# instances based on demand.
# min_size  = minimum instances always running
# max_size  = maximum instances allowed
# desired   = how many to start with
# Instances are spread across private subnets
# in both AZs for high availability
# -------------------------------------------
resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-${var.environment}-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.private_subnet_ids

  # Register instances with the ALB target group
  # so the ALB knows which instances to send traffic to
  target_group_arns = [var.target_group_arn]

  # Health check type ALB means the ASG uses
  # the ALB health check results to decide
  # whether an instance is healthy or not
  health_check_type         = "ELB"
  health_check_grace_period = 300

  # Use the launch template we created in EC2 module
  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  # Replace instances one at a time during updates
  # so there is no downtime
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }
}

# -------------------------------------------
# SCALE OUT POLICY
# Adds instances when CPU is high
# Triggered by CloudWatch alarm
# -------------------------------------------
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.project_name}-${var.environment}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

# -------------------------------------------
# SCALE IN POLICY
# Removes instances when CPU is low
# Triggered by CloudWatch alarm
# -------------------------------------------
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.project_name}-${var.environment}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}
