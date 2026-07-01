# -------------------------------------------
# IAM ROLE for EC2
# This is the identity that EC2 instances
# assume. It defines WHAT the EC2 can do
# in AWS without needing hardcoded credentials
# -------------------------------------------
resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  # Trust policy - allows EC2 service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-role"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -------------------------------------------
# ATTACH CLOUDWATCH POLICY
# Allows EC2 to send logs and metrics
# to CloudWatch for monitoring
# -------------------------------------------
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# -------------------------------------------
# ATTACH SSM POLICY
# Allows EC2 to be managed via AWS Systems Manager
# so you can connect without SSH keys
# -------------------------------------------
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# -------------------------------------------
# ATTACH S3 READ POLICY
# Allows EC2 to read from S3
# e.g. to pull application config or assets
# -------------------------------------------
resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# -------------------------------------------
# INLINE POLICY - Secrets Manager Read
# Allows EC2 to fetch the RDS password
# from Secrets Manager at runtime
# -------------------------------------------
resource "aws_iam_role_policy" "secrets_manager" {
  name = "${var.project_name}-${var.environment}-secrets-read"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "*"
      }
    ]
  })
}

# -------------------------------------------
# INSTANCE PROFILE
# This is what you attach to an EC2 instance
# It wraps the IAM role so EC2 can use it
# -------------------------------------------
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-profile"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
