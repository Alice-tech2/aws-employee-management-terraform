# -------------------------------------------
# LAUNCH TEMPLATE
# Bootstraps EC2 instances with the full
# Flask employee management application.
# App connects to RDS MySQL via credentials
# fetched securely from Secrets Manager.
# -------------------------------------------
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.ec2_sg_id]
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_secret_arn = var.db_secret_arn
    db_host       = var.db_host
    db_name       = var.db_name
    environment   = var.environment
    app_b64       = base64encode(file("${path.module}/app.py"))
  }))

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-${var.environment}-ec2"
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}
