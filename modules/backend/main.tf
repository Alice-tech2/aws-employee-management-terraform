# -------------------------------------------
# S3 BUCKET - Stores the Terraform state file
# Versioning is enabled so you can roll back
# to any previous state if something goes wrong
# -------------------------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  # Prevent accidental deletion of state bucket
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = var.state_bucket_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Enable versioning - keeps full history of state files
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt state file at rest using AES256
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block ALL public access - state files contain sensitive data
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------------------------------------------
# DYNAMODB TABLE - State locking
# Prevents two people running terraform apply
# at the same time and corrupting the state
# -------------------------------------------
resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.dynamodb_table_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
