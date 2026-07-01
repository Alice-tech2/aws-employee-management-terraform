# -------------------------------------------
# VPC
# The private network that all resources live in
# enable_dns_hostnames allows EC2 instances to
# get public DNS names automatically
# -------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -------------------------------------------
# INTERNET GATEWAY
# Connects the VPC to the public internet
# Required for resources in public subnets
# to send and receive internet traffic
# -------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -------------------------------------------
# PUBLIC SUBNETS - one per AZ
# Resources here get public IPs and can be
# reached directly from the internet
# Used for: ALB, NAT Gateway, Bastion hosts
# -------------------------------------------
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Tier        = "Public"
  }
}

# -------------------------------------------
# PRIVATE SUBNETS - one per AZ
# Resources here have NO public IPs
# They access the internet via NAT Gateway
# Used for: EC2 app servers, RDS databases
# -------------------------------------------
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Tier        = "Private"
  }
}

# -------------------------------------------
# ELASTIC IP for NAT Gateway
# NAT Gateway needs a static public IP
# so private subnet traffic always comes
# from the same IP address
# -------------------------------------------
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-eip"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -------------------------------------------
# NAT GATEWAY
# Sits in the PUBLIC subnet and allows
# resources in PRIVATE subnets to reach
# the internet (e.g. to download packages)
# without being directly accessible from internet
# -------------------------------------------
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-gw"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -------------------------------------------
# PUBLIC ROUTE TABLE
# Routes all internet traffic (0.0.0.0/0)
# through the Internet Gateway
# -------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Associate all public subnets with public route table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -------------------------------------------
# PRIVATE ROUTE TABLE
# Routes all internet traffic (0.0.0.0/0)
# through the NAT Gateway instead of IGW
# This keeps private instances secure
# -------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-rt"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Associate all private subnets with private route table
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
