# 🏗️ System Architecture Overview

Our DevOps CI/CD pipeline is built on AWS cloud services with GitHub Actions as the CI/CD engine. This document provides a comprehensive overview of the system architecture.

## 🎯 AWS Services Architecture

### 1. **Amazon ECR (Elastic Container Registry)**
**Purpose**: Container image registry and storage
**Why ECR**: 
- **Security**: Integrated with AWS IAM for access control
- **Performance**: High-speed image pulls within AWS network
- **Integration**: Seamless integration with ECS and other AWS services
- **Cost-effective**: Pay only for storage and data transfer

### 2. **Amazon ECS (Elastic Container Service) with Fargate**
**Purpose**: Container orchestration and runtime environment
**Why ECS Fargate**:
- **Serverless**: No server management required
- **Scalability**: Automatic scaling based on demand
- **Cost-effective**: Pay only for resources used
- **Security**: Isolated compute environment
- **Integration**: Native AWS service integration

### 3. **Application Load Balancer (ALB)**
**Purpose**: Traffic distribution and health monitoring
**Why ALB**:
- **High Availability**: Multi-AZ deployment
- **Health Checks**: Automatic unhealthy instance removal
- **SSL Termination**: Built-in SSL/TLS support
- **Path-based Routing**: Advanced routing capabilities
- **Integration**: Native ECS integration

### 4. **Amazon VPC (Virtual Private Cloud)**
**Purpose**: Network isolation and security
**Why VPC**:
- **Security**: Network-level isolation
- **Control**: Complete network control
- **Compliance**: Meet security requirements
- **Integration**: Native AWS service integration
- **Scalability**: Support for large deployments

### 5. **Amazon CloudWatch**
**Purpose**: Monitoring, logging, and observability
**Why CloudWatch**:
- **Comprehensive**: Metrics, logs, and alarms
- **Integration**: Native AWS service integration
- **Real-time**: Real-time monitoring and alerting
- **Cost-effective**: Basic monitoring included
- **Automation**: Automated responses to events

### 6. **Amazon IAM (Identity and Access Management)**
**Purpose**: Security and access control
**Why IAM**:
- **Security**: Fine-grained access control
- **Compliance**: Meet security requirements
- **Integration**: Native AWS service integration
- **Audit**: Comprehensive access logging
- **Automation**: Programmatic access management

## 🔄 CI/CD Pipeline Architecture

### GitHub Actions Workflow
**Purpose**: Automated CI/CD orchestration
**Why GitHub Actions**:
- **Integration**: Native GitHub integration
- **Flexibility**: Customizable workflows
- **Security**: Secure secrets management
- **Cost-effective**: Free for public repositories
- **Community**: Large ecosystem of actions

### Pipeline Stages:
1. **Version Management**: Automated version detection
2. **Testing**: Unit and integration tests
3. **Quality Checks**: Code quality validation
4. **Building**: Docker image creation
5. **Security Scanning**: Vulnerability detection
6. **Deployment**: AWS service updates
7. **Monitoring**: Health check verification

## 🏗️ Infrastructure as Code (Terraform)

### Terraform Modules
**Purpose**: Reusable infrastructure components
**Why Terraform**:
- **Declarative**: Infrastructure as code
- **Version Control**: Track infrastructure changes
- **Reusability**: Modular architecture
- **State Management**: Track resource state
- **Multi-cloud**: Support for multiple providers

### Module Structure
```
infrastructure/terraform/
├── main.tf                   # Main configuration
├── variables.tf              # Input variables
├── outputs.tf                # Output values
└── modules/                  # Reusable modules
    ├── vpc/                  # VPC and networking
    ├── ecr/                  # Container registry
    ├── ecs/                  # Container orchestration
    ├── alb/                  # Load balancer
    ├── cloudwatch/           # Monitoring and logging
    └── iam/                  # Identity and access management
```

## 🔐 Security Architecture

### Security Layers:
1. **Network Security**: VPC, Security Groups, NACLs
2. **Application Security**: IAM roles, policies
3. **Container Security**: Non-root user, minimal base image
4. **Data Security**: Encryption at rest and in transit
5. **Access Security**: Multi-factor authentication

### Network Security
```hcl
# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Security Groups
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### IAM Security
```hcl
# ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}
```

## 📊 Monitoring and Observability

### Monitoring Stack:
1. **CloudWatch Metrics**: Application and infrastructure metrics
2. **CloudWatch Logs**: Centralized logging
3. **CloudWatch Alarms**: Automated alerting
4. **Application Health Checks**: Endpoint monitoring
5. **Custom Dashboards**: Operational visibility

### CloudWatch Configuration
```hcl
# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "production-devops-cicd-demo-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "production-devops-cicd-demo-service"]
          ]
          period = 300
          stat   = "Average"
          region = "eu-north-1"
          title  = "ECS CPU Utilization"
        }
      }
    ]
  })
}
```

## 🚀 Deployment Strategy

### Deployment Types:
1. **Blue-Green Deployment**: Zero-downtime deployments
2. **Rolling Deployment**: Gradual rollout
3. **Canary Deployment**: Risk mitigation
4. **Immutable Deployment**: Version-based deployments

### ECS Service Configuration
```hcl
# ECS Service
resource "aws_ecs_service" "main" {
  name            = "production-devops-cicd-demo-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "app"
    container_port   = 5000
  }
}
```

## 🔄 Application Architecture

### Flask Application Structure
```
src/
└── hello_world.py              # Main Flask application
    ├── Health Check Endpoint   # /health
    ├── Info Endpoint          # /info
    └── Main Endpoint          # /
```

### Container Architecture
```
Docker Container
├── Python 3.11 Runtime
├── Flask Application
├── Gunicorn WSGI Server
├── Health Check Script
└── Application Code
```

## 📈 Scalability and Performance

### Auto Scaling Configuration
```hcl
# Application Auto Scaling
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based scaling
resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "cpu-auto-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
```

## 🔍 Network Architecture

### VPC Design
```
VPC (10.0.0.0/16)
├── Public Subnets (AZ-a, AZ-b)
│   ├── ALB
│   └── NAT Gateway
└── Private Subnets (AZ-a, AZ-b)
    └── ECS Tasks
```

### Security Group Rules
```hcl
# ALB Security Group
resource "aws_security_group" "alb" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Security Group
resource "aws_security_group" "ecs" {
  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
}
```

## 🚨 High Availability

### Multi-AZ Deployment
- **ALB**: Deployed across multiple AZs
- **ECS Tasks**: Distributed across private subnets
- **NAT Gateway**: Redundant across AZs
- **CloudWatch**: Regional service with redundancy

### Disaster Recovery
- **Backup Strategy**: ECR image versioning
- **Infrastructure**: Terraform state management
- **Application**: Health checks and auto-recovery
- **Data**: CloudWatch logs retention

## 📊 Cost Optimization

### Cost-Saving Strategies
- **Fargate Spot**: Use spot instances for non-critical workloads
- **Auto Scaling**: Scale based on demand
- **Resource Optimization**: Right-size containers
- **Monitoring**: Track and optimize costs
- **Docker Optimization**: Smaller images, efficient layers

### Resource Sizing
```hcl
# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  cpu    = 256  # 0.25 vCPU
  memory = 512  # 512 MB RAM
  
  # Optimized for cost and performance
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
}
```

## 📚 Related Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)**: Detailed architecture documentation
- **[ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)**: Architecture diagrams
- **[SETUP.md](SETUP.md)**: Infrastructure setup guide
- **[OPTIMIZATION.md](OPTIMIZATION.md)**: Performance optimization strategies

---

**Note**: This architecture provides a scalable, secure, and cost-effective foundation for the DevOps CI/CD pipeline with comprehensive monitoring and automation capabilities. 