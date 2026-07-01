# -------------------------------------------
# BACKEND MODULE
# Creates S3 bucket and DynamoDB table
# Run this FIRST before adding the backend
# block to provider.tf
# -------------------------------------------
module "backend" {
  source = "./modules/backend"

  state_bucket_name   = var.state_bucket_name
  dynamodb_table_name = var.dynamodb_table_name
  environment         = var.environment
  project_name        = var.project_name
}

# -------------------------------------------
# VPC MODULE
# Creates all networking resources
# Everything else depends on this
# -------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# -------------------------------------------
# SECURITY GROUPS MODULE
# Creates ALB and EC2 security groups
# Depends on VPC
# -------------------------------------------
module "sg" {
  source = "./modules/sg"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = module.vpc.vpc_cidr
}

# -------------------------------------------
# IAM MODULE
# Creates EC2 role and instance profile
# No dependencies
# -------------------------------------------
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

# -------------------------------------------
# ALB MODULE
# Creates load balancer, target group, listener
# Depends on VPC and SG
# -------------------------------------------
module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.sg.alb_sg_id
}

# -------------------------------------------
# RDS MODULE
# Creates MySQL database, subnet group,
# and stores credentials in Secrets Manager
# Depends on VPC and SG
# -------------------------------------------
module "rds" {
  source = "./modules/rds"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.sg.rds_sg_id
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  db_instance_class  = var.db_instance_class
}

# Creates launch template for ASG
# Depends on SG and IAM
# -------------------------------------------
module "ec2" {
  source = "./modules/ec2"

  project_name          = var.project_name
  environment           = var.environment
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  ec2_sg_id             = module.sg.ec2_sg_id
  instance_profile_name = module.iam.ec2_instance_profile_name
  db_host               = module.rds.db_host
  db_name               = module.rds.db_name
  db_secret_arn         = module.rds.db_secret_arn
}

# -------------------------------------------
# ASG MODULE
# Creates Auto Scaling Group
# Depends on EC2 launch template and ALB
# -------------------------------------------
module "asg" {
  source = "./modules/asg"

  project_name            = var.project_name
  environment             = var.environment
  min_size                = var.asg_min_size
  max_size                = var.asg_max_size
  desired_capacity        = var.asg_desired_capacity
  private_subnet_ids      = module.vpc.private_subnet_ids
  target_group_arn        = module.alb.target_group_arn
  launch_template_id      = module.ec2.launch_template_id
  launch_template_version = module.ec2.launch_template_version
}

# -------------------------------------------
# CLOUDWATCH MODULE
# Creates alarms and dashboard
# Depends on ASG and ALB
# -------------------------------------------
module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name         = var.project_name
  environment          = var.environment
  region               = var.region
  asg_name             = module.asg.asg_name
  scale_out_policy_arn = module.asg.scale_out_policy_arn
  scale_in_policy_arn  = module.asg.scale_in_policy_arn
  alb_arn_suffix       = module.alb.alb_arn
}
