terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # -------------------------------------------
  # REMOTE BACKEND
  # State is stored in S3 and locked with DynamoDB
  # The bucket and table must exist before running
  # terraform init on this root config.
  # Run the backend module first to create them.
  # -------------------------------------------
  backend "s3" {
    bucket       = "devops-project-state-us-east-2"
    key          = "devops-project/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "devops-project"
      ManagedBy = "Terraform"
    }
  }
}
