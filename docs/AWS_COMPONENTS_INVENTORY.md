# 🏗️ AWS Components Inventory

This document provides a comprehensive inventory of all AWS services, resources, and components used in the DevOps CI/CD pipeline project.

## 📋 Overview

The project utilizes a comprehensive set of AWS services to create a production-ready DevOps CI/CD pipeline. This inventory covers all resources created by Terraform and used by the application.

## 🎯 Core AWS Services

### 1. **Amazon ECR (Elastic Container Registry)**
**Purpose**: Container image registry and storage

#### Resources Created:
- **Repository**: `devops-cicd-demo`
- **Repository URL**: `485701710361.dkr.ecr.eu-north-1.amazonaws.com/devops-cicd-demo`
- **Image Tag Mutability**: MUTABLE
- **Image Scanning**: ✅ Enabled (automatic vulnerability scanning)
- **Lifecycle Policy**: ✅ Configured (keeps last 30 images)

#### Configuration:
```hcl
resource "aws_ecr_repository" "main" {
  name                 = "devops-cicd-demo"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 30 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 30
      }
      action = { type = "expire" }
    }]
  })
}
```

### 2. **Amazon ECS (Elastic Container Service)**
**Purpose**: Container orchestration and management

#### Resources Created:
- **Cluster**: `production-devops-cicd-demo-cluster`
- **Service**: `production-devops-cicd-demo-service`
- **Task Definition**: `production-devops-cicd-demo-task`
- **Launch Type**: FARGATE (serverless)
- **Desired Count**: 2 tasks
- **CPU**: 256 units (0.25 vCPU)
- **Memory**: 512 MB

#### Container Configuration:
```hcl
resource "aws_ecs_task_definition" "app" {
  family                   = "production-devops-cicd-demo-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  
  container_definitions = jsonencode([{
    name  = "production-devops-cicd-demo-container"
    image = "${var.ecr_repository_url}:latest"
    portMappings = [{ containerPort = 5000, protocol = "tcp" }]
    environment = [
      { name = "ENVIRONMENT", value = "production" },
      { name = "APP_NAME", value = "devops-cicd-demo" }
    ]
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:5000/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }])
}
```

### 3. **Application Load Balancer (ALB)**
**Purpose**: Traffic distribution and health monitoring

#### Resources Created:
- **Load Balancer**: `production-devops-cicd-demo-alb`
- **DNS Name**: `production-devops-cicd-demo-alb-685489736.eu-north-1.elb.amazonaws.com`
- **Type**: Application Load Balancer
- **Scheme**: internet-facing
- **IP Address Type**: ipv4

#### Target Group Configuration:
- **Target Group**: `production-devops-cicd-demo-tg`
- **Target Type**: IP
- **Port**: 5000
- **Protocol**: HTTP
- **Health Check Path**: `/health`
- **Health Check Interval**: 30 seconds
- **Healthy Threshold**: 2
- **Unhealthy Threshold**: 2

#### Security Group:
- **Name**: `production-devops-cicd-demo-alb-sg`
- **Inbound Rules**:
  - HTTP (80): 0.0.0.0/0
  - HTTPS (443): 0.0.0.0/0
- **Outbound Rules**: All traffic (0.0.0.0/0)

### 4. **Amazon VPC (Virtual Private Cloud)**
**Purpose**: Network isolation and security

#### Resources Created:
- **VPC ID**: `vpc-0de56a243be2e38d7`
- **CIDR Block**: `10.0.0.0/16`
- **DNS Hostnames**: Enabled
- **DNS Support**: Enabled

#### Subnets:
**Public Subnets** (for ALB and NAT Gateway):
- `subnet-0c9449d9c4b6b39f3` (eu-north-1a, 10.0.1.0/24)
- `subnet-0e8260a72ef0732cb` (eu-north-1b, 10.0.2.0/24)

**Private Subnets** (for ECS tasks):
- `subnet-0aa5e16778f6a2b17` (eu-north-1a, 10.0.3.0/24)
- `subnet-0b8a5267d57f3e7a9` (eu-north-1b, 10.0.4.0/24)

#### Network Components:
- **Internet Gateway**: `igw-0c0d7381483b13999`
- **NAT Gateway**: `nat-037df337f3c91d29d`
- **Elastic IP**: `16.16.42.92` (for NAT Gateway)

#### Route Tables:
- **Public Route Table**: Routes internet traffic via Internet Gateway
- **Private Route Table**: Routes internet traffic via NAT Gateway

### 5. **Amazon CloudWatch**
**Purpose**: Monitoring, logging, and observability

#### Resources Created:
- **Log Group**: `/ecs/production-devops-cicd-demo`
- **Retention**: 30 days
- **Dashboard**: `production-devops-cicd-demo-dashboard`

#### Alarms:
- **CPU Alarm**: `production-devops-cicd-demo-cpu-high`
  - Metric: CPUUtilization
  - Threshold: 80%
  - Evaluation Periods: 2
  - Period: 300 seconds

- **Memory Alarm**: `production-devops-cicd-demo-memory-high`
  - Metric: MemoryUtilization
  - Threshold: 80%
  - Evaluation Periods: 2
  - Period: 300 seconds

#### Dashboard Widgets:
- ECS Service Metrics (CPU, Memory)
- ALB Metrics (Request Count, Response Time)

### 6. **Amazon IAM (Identity and Access Management)**
**Purpose**: Security and access control

#### Resources Created:

**GitHub Actions Role**:
- **Role Name**: `production-devops-cicd-demo-github-actions-role`
- **Trust Policy**: GitHub Actions OIDC
- **Permissions**:
  - ECR: Full access (push/pull images)
  - ECS: Service management
  - IAM: Pass role permissions

**ECS Execution Role**:
- **Role Name**: `production-devops-cicd-demo-ecs-execution-role`
- **Trust Policy**: ECS tasks
- **Permissions**:
  - ECR: Pull images
  - CloudWatch: Write logs
  - ECS: Task execution

**ECS Task Role**:
- **Role Name**: `production-devops-cicd-demo-ecs-task-role`
- **Trust Policy**: ECS tasks
- **Permissions**: Application-specific permissions

## 🔧 Supporting AWS Services

### 7. **AWS Secrets Manager** (Optional)
**Purpose**: Secure secret storage

#### Usage Examples:
```bash
# Store AWS credentials
aws secretsmanager create-secret \
  --name "devops-cicd-demo/aws-credentials" \
  --secret-string '{"access_key_id":"your_key","secret_access_key":"your_secret"}' \
  --region eu-north-1

# Store application secrets
aws secretsmanager create-secret \
  --name "devops-cicd-demo/app-secrets" \
  --secret-string '{"database_url":"your_db_url","api_key":"your_api_key"}' \
  --region eu-north-1
```

### 8. **AWS Systems Manager Parameter Store** (Optional)
**Purpose**: Configuration management

#### Usage Examples:
```bash
# Store application configuration
aws ssm put-parameter \
  --name "/devops-cicd-demo/environment" \
  --value "production" \
  --type "String" \
  --region eu-north-1

# Store database connection string
aws ssm put-parameter \
  --name "/devops-cicd-demo/database-url" \
  --value "postgresql://user:pass@host:5432/db" \
  --type "SecureString" \
  --region eu-north-1
```

## 📊 Resource Inventory Summary

### Infrastructure Resources:
| Service | Resource Type | Count | Names |
|---------|---------------|-------|-------|
| VPC | VPC | 1 | `production-vpc` |
| VPC | Subnets | 4 | 2 public, 2 private |
| VPC | Internet Gateway | 1 | `production-igw` |
| VPC | NAT Gateway | 1 | `production-nat-gateway` |
| VPC | Route Tables | 2 | Public and Private |
| ECR | Repository | 1 | `devops-cicd-demo` |
| ECR | Lifecycle Policy | 1 | Keep last 30 images |
| ECS | Cluster | 1 | `production-devops-cicd-demo-cluster` |
| ECS | Service | 1 | `production-devops-cicd-demo-service` |
| ECS | Task Definition | 1 | `production-devops-cicd-demo-task` |
| ALB | Load Balancer | 1 | `production-devops-cicd-demo-alb` |
| ALB | Target Group | 1 | `production-devops-cicd-demo-tg` |
| ALB | Listener | 1 | HTTP (80) |
| Security Groups | ALB SG | 1 | `production-devops-cicd-demo-alb-sg` |
| Security Groups | ECS SG | 1 | `production-devops-cicd-demo-ecs-tasks-sg` |
| IAM | Roles | 3 | GitHub Actions, ECS Execution, ECS Task |
| CloudWatch | Log Group | 1 | `/ecs/production-devops-cicd-demo` |
| CloudWatch | Dashboard | 1 | `production-devops-cicd-demo-dashboard` |
| CloudWatch | Alarms | 2 | CPU and Memory alarms |

### Total Resources: **25 AWS Resources**

## 🔍 Resource Verification Commands

### Check VPC Resources:
```bash
# List VPCs
aws ec2 describe-vpcs --filters "Name=tag:Environment,Values=production"

# List subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-0de56a243be2e38d7"

# List security groups
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=vpc-0de56a243be2e38d7"
```

### Check ECR Resources:
```bash
# List repositories
aws ecr describe-repositories --repository-names devops-cicd-demo

# List images
aws ecr describe-images --repository-name devops-cicd-demo
```

### Check ECS Resources:
```bash
# List clusters
aws ecs list-clusters

# Describe cluster
aws ecs describe-clusters --clusters production-devops-cicd-demo-cluster

# List services
aws ecs list-services --cluster production-devops-cicd-demo-cluster

# Describe service
aws ecs describe-services \
  --cluster production-devops-cicd-demo-cluster \
  --services production-devops-cicd-demo-service
```

### Check ALB Resources:
```bash
# List load balancers
aws elbv2 describe-load-balancers \
  --names production-devops-cicd-demo-alb

# List target groups
aws elbv2 describe-target-groups \
  --names production-devops-cicd-demo-tg

# Check target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>
```

### Check CloudWatch Resources:
```bash
# List log groups
aws logs describe-log-groups --log-group-name-prefix "/ecs/production-devops-cicd-demo"

# List dashboards
aws cloudwatch list-dashboards

# List alarms
aws cloudwatch describe-alarms --alarm-names \
  production-devops-cicd-demo-cpu-high \
  production-devops-cicd-demo-memory-high
```

### Check IAM Resources:
```bash
# List roles
aws iam list-roles --path-prefix "/aws-service-role/"

# Get role details
aws iam get-role --role-name production-devops-cicd-demo-github-actions-role
```

## 🚀 Resource URLs

### AWS Console Links:
- **VPC Console**: https://eu-north-1.console.aws.amazon.com/vpc/
- **ECR Console**: https://eu-north-1.console.aws.amazon.com/ecr/
- **ECS Console**: https://eu-north-1.console.aws.amazon.com/ecs/
- **ALB Console**: https://eu-north-1.console.aws.amazon.com/ec2/v2/home?region=eu-north-1#LoadBalancer:
- **CloudWatch Console**: https://eu-north-1.console.aws.amazon.com/cloudwatch/
- **IAM Console**: https://console.aws.amazon.com/iam/

### Application URLs:
- **Main Application**: http://production-devops-cicd-demo-alb-685489736.eu-north-1.elb.amazonaws.com/
- **Health Check**: http://production-devops-cicd-demo-alb-685489736.eu-north-1.elb.amazonaws.com/health
- **Info Endpoint**: http://production-devops-cicd-demo-alb-685489736.eu-north-1.elb.amazonaws.com/info

## 💰 Cost Estimation

### Monthly Costs (Estimated):
- **ECR**: ~$5-10 (storage and data transfer)
- **ECS Fargate**: ~$50-100 (2 tasks, 256 CPU, 512 MB memory)
- **ALB**: ~$20-30 (load balancer hours and data processing)
- **NAT Gateway**: ~$45-50 (per hour + data processing)
- **CloudWatch**: ~$10-20 (logs, metrics, alarms)
- **VPC**: ~$5-10 (NAT Gateway data processing)

**Total Estimated Monthly Cost**: $135-220

## 🔒 Security Considerations

### Network Security:
- Private subnets for ECS tasks
- Public subnets only for ALB and NAT Gateway
- Security groups with minimal required access
- No direct internet access for application containers

### IAM Security:
- Least privilege principle
- Role-based access control
- No hardcoded credentials
- GitHub Actions OIDC integration

### Container Security:
- Non-root user execution
- Image vulnerability scanning
- Minimal base images
- Regular security updates

## 📈 Scalability Features

### Auto-scaling Capabilities:
- ECS service auto-scaling based on CPU/Memory
- ALB cross-zone load balancing
- Multi-AZ deployment for high availability
- Fargate automatic resource allocation

### Monitoring and Alerting:
- CloudWatch dashboards for real-time monitoring
- Automated alarms for performance issues
- Log aggregation and analysis
- Custom metrics and alerts

---

**Note**: This inventory represents a production-ready AWS infrastructure with comprehensive monitoring, security, and scalability features. All resources are managed through Terraform for infrastructure as code practices. 