# DevOps CI/CD Demo - Architecture Documentation

## Overview

This project demonstrates a complete CI/CD pipeline using AWS services for a Python microservice. The architecture follows modern DevOps practices with Infrastructure as Code, containerization, and automated deployments.

## Architecture Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │  GitHub Actions │    │   AWS Services  │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ Source Code │ │───▶│ │ CI/CD       │ │───▶│ │ ECR         │ │
│ │             │ │    │ │ Pipeline    │ │    │ │ (Registry)  │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    │                 │
                                              │ ┌─────────────┐ │
                                              │ │ ECS         │ │
                                              │ │ (Fargate)   │ │
                                              │ └─────────────┘ │
                                              │                 │
                                              │ ┌─────────────┐ │
                                              │ │ ALB         │ │
                                              │ │ (Load       │ │
                                              │ │ Balancer)   │ │
                                              │ └─────────────┘ │
                                              └─────────────────┘
                                                       │
                                                       ▼
                                              ┌─────────────────┐
                                              │   End Users     │
                                              │                 │
                                              │ ┌─────────────┐ │
                                              │ │ Web Browser │ │
                                              │ │ / API Client│ │
                                              │ └─────────────┘ │
                                              └─────────────────┘
```

## Component Details

### 1. Source Code Management

**GitHub Repository**
- Public repository for source code
- Branch protection rules for main branch
- Automated workflows triggered by pushes and pull requests

**Application**
- Python Flask microservice
- Health check endpoints
- Version information exposed via API
- Containerized with Docker

### 2. CI/CD Pipeline

**GitHub Actions Workflow**
- **Trigger**: Push to main branch, pull requests, releases
- **Jobs**:
  - Test: Lint code, run unit tests
  - Build: Create Docker image, push to ECR
  - Deploy: Update ECS service with new image
  - Tag: Create Git tags for releases

**Versioning Strategy**
- Semantic versioning (Major.Minor.Patch)
- Git tags for releases
- Date-based versioning for development builds
- Docker image tagging with versions

### 3. AWS Infrastructure

#### VPC and Networking
```
┌─────────────────────────────────────────────────────────────┐
│                        VPC                                │
│  ┌─────────────────┐    ┌─────────────────┐              │
│  │ Public Subnets  │    │ Private Subnets │              │
│  │                 │    │                 │              │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │              │
│  │ │ ALB         │ │    │ │ ECS Tasks   │ │              │
│  │ │ (Internet   │ │    │ │ (No Public  │ │              │
│  │ │ Facing)     │ │    │ │ IP)          │ │              │
│  │ └─────────────┘ │    │ └─────────────┘ │              │
│  │                 │    │                 │              │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │              │
│  │ │ NAT Gateway │ │    │ │ ECS Tasks   │ │              │
│  │ │ (Outbound   │ │    │ │ (No Public  │ │              │
│  │ │ Internet)   │ │    │ │ IP)          │ │              │
│  │ └─────────────┘ │    │ └─────────────┘ │              │
│  └─────────────────┘    └─────────────────┘              │
└─────────────────────────────────────────────────────────────┘
```

#### Container Registry (ECR)
- **Repository**: Stores Docker images
- **Lifecycle Policy**: Keeps last 30 images
- **Image Scanning**: Automatic vulnerability scanning
- **Access Control**: IAM-based permissions

#### Container Orchestration (ECS)
- **Cluster**: Logical grouping of services
- **Service**: Manages task instances
- **Task Definition**: Container specification
- **Fargate**: Serverless compute (no EC2 management)

#### Load Balancer (ALB)
- **Public Access**: Internet-facing
- **Health Checks**: Monitors application health
- **Target Groups**: Routes traffic to ECS tasks
- **Security Groups**: Controls network access

### 4. Security Architecture

#### Network Security
```
┌─────────────────────────────────────────────────────────────┐
│                    Security Groups                         │
│                                                           │
│ ┌─────────────────┐    ┌─────────────────┐              │
│ │ ALB SG          │    │ ECS Tasks SG    │              │
│ │                 │    │                 │              │
│ │ Inbound:        │    │ Inbound:        │              │
│ │ - HTTP (80)     │    │ - HTTP (5000)   │              │
│ │ - HTTPS (443)   │    │ from ALB SG     │              │
│ │                 │    │                 │              │
│ │ Outbound:       │    │ Outbound:       │              │
│ │ - All (0.0.0.0)│    │ - All (0.0.0.0)│              │
│ └─────────────────┘    └─────────────────┘              │
└─────────────────────────────────────────────────────────────┘
```

#### IAM Roles and Policies
- **ECS Execution Role**: Pulls images from ECR, writes logs to CloudWatch
- **ECS Task Role**: Application-specific permissions
- **GitHub Actions Role**: CI/CD pipeline permissions

### 5. Monitoring and Observability

#### CloudWatch Integration
- **Logs**: Application and container logs
- **Metrics**: ECS, ALB, and custom metrics
- **Dashboards**: Real-time monitoring
- **Alarms**: Automated alerting

#### Health Checks
- **Application Level**: `/health` endpoint
- **Container Level**: Docker health checks
- **Load Balancer**: ALB health checks
- **ECS Service**: Service health monitoring

## Data Flow

### 1. Code Push Flow
```
Developer Push → GitHub → GitHub Actions → AWS ECR → ECS → ALB → Users
```

### 2. Request Flow
```
User Request → ALB → ECS Task → Application → Response
```

### 3. Monitoring Flow
```
Application → CloudWatch Logs → CloudWatch Metrics → Dashboard/Alarms
```

## Scalability Considerations

### Horizontal Scaling
- **ECS Service**: Auto-scaling based on CPU/Memory
- **ALB**: Distributes load across multiple tasks
- **Fargate**: Automatic resource allocation

### Vertical Scaling
- **Task Definition**: CPU/Memory limits
- **Container Resources**: Optimized for application needs

## High Availability

### Multi-AZ Deployment
- **Subnets**: Distributed across availability zones
- **ECS Tasks**: Spread across AZs
- **ALB**: Cross-zone load balancing

### Fault Tolerance
- **Health Checks**: Automatic task replacement
- **Rolling Updates**: Zero-downtime deployments
- **Auto Recovery**: Failed tasks automatically restarted

## Cost Optimization

### Resource Optimization
- **Fargate**: Pay only for resources used
- **Right-sizing**: Optimize CPU/Memory allocation
- **Lifecycle Policies**: Automatic cleanup of old images

### Monitoring Costs
- **CloudWatch**: Monitor resource usage
- **Cost Alerts**: Set up billing alarms
- **Resource Tagging**: Track costs by environment

## Disaster Recovery

### Backup Strategy
- **Source Code**: GitHub repository
- **Infrastructure**: Terraform state
- **Application Data**: Stateless design

### Recovery Procedures
- **Infrastructure**: Terraform apply
- **Application**: ECS service restart
- **Data**: No persistent data to recover

## Performance Optimization

### Container Optimization
- **Multi-stage Builds**: Smaller image sizes
- **Layer Caching**: Faster builds
- **Security Scanning**: Vulnerability detection

### Network Optimization
- **VPC Endpoints**: Private AWS service access
- **Security Groups**: Minimal required access
- **ALB Optimization**: Connection draining

## Security Best Practices

### Container Security
- **Non-root User**: Application runs as non-root
- **Image Scanning**: Automatic vulnerability detection
- **Secrets Management**: Environment variables for sensitive data

### Network Security
- **Private Subnets**: ECS tasks in private subnets
- **Security Groups**: Least privilege access
- **NAT Gateway**: Controlled outbound access

### Access Control
- **IAM Roles**: Service-specific permissions
- **GitHub OIDC**: Secure CI/CD authentication
- **Resource Tagging**: Access control by tags

## Future Enhancements

### Advanced Features
1. **Blue/Green Deployments**: Zero-downtime deployments
2. **Canary Deployments**: Gradual rollout
3. **Service Mesh**: Advanced traffic management
4. **API Gateway**: API management and security
5. **CDN**: Global content delivery

### Monitoring Enhancements
1. **Distributed Tracing**: Request tracing across services
2. **Custom Metrics**: Application-specific monitoring
3. **Alerting**: Advanced notification systems
4. **Log Aggregation**: Centralized log management

### Security Enhancements
1. **WAF**: Web application firewall
2. **Secrets Manager**: Centralized secrets management
3. **Certificate Manager**: SSL/TLS certificate management
4. **Security Hub**: Security posture monitoring 