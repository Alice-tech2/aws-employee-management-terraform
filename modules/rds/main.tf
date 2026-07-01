# -------------------------------------------
# SECRETS MANAGER - DB Password
# Stores the RDS password securely so EC2
# can fetch it at runtime without hardcoding
# -------------------------------------------
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}-${var.environment}-db-password"
  description             = "RDS MySQL master password"
  recovery_window_in_days = 0

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-password"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

# -------------------------------------------
# RDS SUBNET GROUP
# Tells RDS which subnets it can use
# Must span at least 2 AZs for Multi-AZ support
# We use private subnets so DB is never public
# -------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -------------------------------------------
# RDS MYSQL INSTANCE
# Single-AZ dev instance (Multi-AZ for prod)
# Sits in private subnets, not publicly accessible
# Automated backups retained for 7 days
# -------------------------------------------
resource "aws_db_instance" "main" {
  identifier        = "${var.project_name}-${var.environment}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]

  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-mysql"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
