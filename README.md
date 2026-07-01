# Employee Management System — AWS Infrastructure with Terraform

A production-ready Employee Management web application deployed on AWS using Terraform. Built with a fully automated infrastructure including Auto Scaling, Load Balancing, RDS MySQL, and CloudWatch monitoring — all provisioned as code.

---

## Live Architecture

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────────┐
│                  Application Load Balancer           │
│              (Public Subnets — us-east-2a/2b)        │
└──────────────────────┬──────────────────────────────┘
                       │ HTTP :80
          ┌────────────▼────────────┐
          │    Auto Scaling Group   │
          │  ┌──────┐   ┌──────┐   │
          │  │ EC2  │   │ EC2  │   │  ← Flask App (Private Subnets)
          │  └──┬───┘   └──┬───┘   │
          └─────┼──────────┼───────┘
                │          │ MySQL :3306
          ┌─────▼──────────▼───────┐
          │      RDS MySQL 8.0     │
          │   (Private Subnets)    │
          └────────────────────────┘
```

---

## Features

- **Employee CRUD** — Add, view, and delete employees via a clean web UI
- **Employee Fields** — First/Last name, Email, Department, Role, Salary, Start Date, Status
- **Live Dashboard** — Stats cards showing total, active, inactive employees and average salary
- **Auto Scaling** — Scales out at 70% CPU, scales in at 20% CPU
- **High Availability** — Multi-AZ deployment across `us-east-2a` and `us-east-2b`
- **Secure by Design** — RDS in private subnets, credentials in Secrets Manager, no hardcoded secrets
- **State Management** — Remote state in S3 with DynamoDB locking

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| IaC | Terraform >= 1.5 |
| Cloud | AWS (us-east-2) |
| App | Python 3 + Flask |
| Database | RDS MySQL 8.0 |
| Web Server | Flask (port 80) |
| Load Balancer | AWS ALB |
| Scaling | AWS Auto Scaling Group |
| Secrets | AWS Secrets Manager |
| Monitoring | AWS CloudWatch |
| State Backend | S3 + DynamoDB |

---

## Project Structure

```
devops-project/
├── main.tf                  # Root module — wires all modules together
├── provider.tf              # AWS provider + S3 backend config
├── variables.tf             # All input variable declarations
├── outputs.tf               # Root outputs (ALB DNS, RDS endpoint, etc.)
├── terraform.tfvars         # Variable values for dev environment
└── modules/
    ├── backend/             # S3 bucket + DynamoDB for remote state
    ├── vpc/                 # VPC, subnets, IGW, NAT Gateway, route tables
    ├── sg/                  # Security groups (ALB, EC2, RDS)
    ├── iam/                 # EC2 IAM role + instance profile
    ├── alb/                 # Application Load Balancer + target group
    ├── ec2/                 # Launch template with Flask app bootstrap
    ├── asg/                 # Auto Scaling Group + scaling policies
    ├── rds/                 # RDS MySQL + Secrets Manager
    └── cloudwatch/          # Alarms (CPU high/low) + dashboard
```

---

## Infrastructure Overview

### Networking (VPC Module)
- VPC CIDR: `10.0.0.0/16`
- 2 Public subnets (`10.0.1.0/24`, `10.0.2.0/24`) — ALB lives here
- 2 Private subnets (`10.0.3.0/24`, `10.0.4.0/24`) — EC2 and RDS live here
- NAT Gateway — allows private instances to reach the internet for updates
- Internet Gateway — allows public subnets to receive inbound traffic

### Security Groups
| Group | Inbound | Outbound |
|-------|---------|----------|
| ALB SG | 80, 443 from `0.0.0.0/0` | All |
| EC2 SG | 80 from ALB SG only, 22 from VPC CIDR | All |
| RDS SG | 3306 from EC2 SG only | All |

### Auto Scaling
- Min: 1 instance, Max: 3 instances, Desired: 2
- Scale out: CPU > 70% for 4 minutes → add 1 instance
- Scale in: CPU < 20% for 4 minutes → remove 1 instance
- Rolling instance refresh on launch template updates (50% min healthy)

### RDS MySQL
- Engine: MySQL 8.0
- Instance: `db.t3.micro`
- Storage: 20GB gp2, encrypted at rest
- Automated backups: 7-day retention
- Not publicly accessible — only reachable from EC2 SG

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- [AWS CLI](https://aws.amazon.com/cli/) configured with a profile
- An AWS IAM user with sufficient permissions

---

## CI/CD Pipeline

This project uses GitHub Actions for automated deployments.

| Trigger | Action |
|---------|--------|
| Pull Request opened | Runs `terraform plan` and posts output as PR comment |
| Push to `main` | Runs `terraform apply` automatically |
| Manual trigger | Run plan, apply or destroy from GitHub Actions UI |

### Pipeline Flow

```
Pull Request
     │
     ▼
 terraform init
 terraform validate
 terraform fmt -check
 terraform plan ──► posts plan as PR comment
     │
  Merge to main
     │
     ▼
 terraform apply ──► infrastructure updated on AWS
```

### Required GitHub Secrets

Go to your repo → **Settings → Secrets and variables → Actions** and add:

| Secret | Value |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | Your IAM user access key |
| `AWS_SECRET_ACCESS_KEY` | Your IAM user secret key |
| `TF_VAR_DB_PASSWORD` | Your RDS master password |

---


### 1. Create the S3 backend bucket manually (one-time)

```bash
aws s3 mb s3://devops-project-state-us-east-2 --region us-east-2
```

### 2. Clone and initialise

```bash
git clone https://github.com/<your-username>/devops-project.git
cd devops-project
terraform init
```

### 3. Review the plan

```bash
terraform plan
```

### 4. Deploy

```bash
terraform apply
```

Type `yes` when prompted. Full deployment takes approximately **8–12 minutes** (RDS takes the longest).

### 5. Access the app

After apply completes, grab the ALB DNS name from the output:

```bash
terraform output alb_dns_name
```

Open it in your browser — the Employee Management app will be live.

### 6. Destroy when done

```bash
terraform destroy
```

---

## Environment Variables

All values are configured in `terraform.tfvars`:

| Variable | Description | Default |
|----------|-------------|---------|
| `region` | AWS region | `us-east-2` |
| `environment` | dev / stg / prod | `dev` |
| `project_name` | Used for all resource names | `devops-project` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `ami_id` | Amazon Linux 2 AMI | `ami-04a8291398335a9ac` |
| `instance_type` | EC2 instance type | `t3.micro` |
| `db_name` | MySQL database name | `employeedb` |
| `db_username` | MySQL master user | `admin` |
| `db_password` | MySQL password (sensitive) | — |
| `db_instance_class` | RDS instance type | `db.t3.micro` |

> **Never commit `terraform.tfvars` containing real passwords to Git.** Add it to `.gitignore` or use environment variables.

---

## Security Best Practices Applied

- RDS is in private subnets — never publicly accessible
- DB credentials stored in AWS Secrets Manager — never hardcoded
- EC2 instances use IAM roles — no access keys on instances
- State file encrypted at rest in S3
- Security groups follow least-privilege (EC2 only accepts traffic from ALB, RDS only from EC2)
- `sensitive = true` on all password outputs

---

## Monitoring

CloudWatch Dashboard: `devops-project-dev-dashboard`

| Widget | Metric |
|--------|--------|
| CPU Utilization | `AWS/EC2 CPUUtilization` per ASG |
| ALB Request Count | `AWS/ApplicationELB RequestCount` |
| Healthy Host Count | `AWS/ApplicationELB HealthyHostCount` |

Alarms:
- `devops-project-dev-cpu-high` — triggers scale out at >70% CPU
- `devops-project-dev-cpu-low` — triggers scale in at <20% CPU

---

## .gitignore

```
.terraform/
terraform.tfstate
terraform.tfstate.backup
*.tfvars
tfplan
.terraform.lock.hcl
```

---

## Author

Built as a hands-on DevOps project to demonstrate production-grade AWS infrastructure using Terraform — covering networking, compute, database, security, auto scaling, and monitoring.
