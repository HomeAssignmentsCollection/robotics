# DevOps CI/CD Demo - Setup Guide

This guide will help you set up the complete CI/CD pipeline for the DevOps demo project.

## Prerequisites

### Required Tools
- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com/)
- [AWS CLI](https://aws.amazon.com/cli/)
- [Terraform](https://www.terraform.io/) (v1.0+)
- [Python](https://www.python.org/) (3.11+)

### AWS Account Setup
1. Create an AWS account if you don't have one
2. Create an IAM user with appropriate permissions
3. Configure AWS CLI with your credentials:
   ```bash
   aws configure
   ```

## Project Structure

```
.
├── src/
│   └── hello_world.py          # Flask application
├── docker/
│   └── Dockerfile              # Multi-stage Docker build
├── infrastructure/
│   ├── terraform/              # Infrastructure as Code
│   └── scripts/                # Deployment scripts
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # GitHub Actions workflow
├── tests/
│   └── test_hello_world.py    # Application tests
├── requirements.txt            # Python dependencies
└── README.md                  # Project documentation
```

## Step-by-Step Setup

### 1. Clone and Initialize Repository

```bash
# Clone the repository
git clone <your-repo-url>
cd devops-cicd-demo

# Initialize git repository (if not already done)
git init
git add .
git commit -m "Initial commit"
```

### 2. Create GitHub Repository

1. Go to GitHub and create a new public repository
2. Name it `devops-cicd-demo` or similar
3. Push your code to GitHub:
   ```bash
   git remote add origin <your-github-repo-url>
   git push -u origin main
   ```

### 3. Configure GitHub Secrets

In your GitHub repository, go to Settings > Secrets and variables > Actions, and add the following secrets:

- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### 4. Deploy Infrastructure

```bash
# Make scripts executable
chmod +x infrastructure/scripts/deploy.sh
chmod +x infrastructure/scripts/destroy.sh

# Deploy infrastructure
./infrastructure/scripts/deploy.sh
```

### 5. Update GitHub Actions Workflow

Update the workflow file `.github/workflows/ci-cd.yml` with your specific values:

```yaml
env:
  AWS_REGION: us-east-1  # Your AWS region
  ECR_REPOSITORY: devops-cicd-demo  # Your ECR repository name
  ECS_CLUSTER: production-devops-cicd-demo-cluster  # From Terraform output
  ECS_SERVICE: production-devops-cicd-demo-service  # From Terraform output
  ECS_TASK_DEFINITION: production-devops-cicd-demo-task  # From Terraform output
```

### 6. Test the Pipeline

1. Make a small change to `src/hello_world.py`
2. Commit and push to GitHub:
   ```bash
   git add .
   git commit -m "Test CI/CD pipeline"
   git push
   ```
3. Monitor the pipeline in GitHub Actions
4. Check the deployment in AWS Console

## Versioning Strategy

### Semantic Versioning
- **Major.Minor.Patch** (e.g., 1.0.0, 1.0.1, 1.1.0)
- Automated versioning based on:
  - Git tags for releases
  - Date-based versioning for development builds

### Docker Image Tagging
- `latest`: Latest build
- `{version}`: Specific version (e.g., 1.0.0)
- `{date}-{commit}`: Development builds

## AWS Services Used

### Core Services
- **ECR**: Container registry for Docker images
- **ECS**: Container orchestration with Fargate
- **ALB**: Application load balancer for external access
- **VPC**: Network infrastructure with public/private subnets

### Supporting Services
- **IAM**: Security and permissions
- **CloudWatch**: Monitoring and logging
- **Route 53**: DNS (optional for custom domains)

## Monitoring and Logging

### CloudWatch Dashboard
- ECS service metrics (CPU, Memory)
- ALB metrics (Request count, Response time)
- Custom application logs

### Health Checks
- Application health endpoint: `/health`
- ALB health checks configured
- ECS task health checks

## Security Considerations

### Network Security
- Private subnets for ECS tasks
- Public subnets for ALB only
- Security groups with minimal required access
- NAT Gateway for outbound internet access

### IAM Security
- Least privilege principle
- Role-based access control
- GitHub Actions OIDC integration (recommended)

## Troubleshooting

### Common Issues

1. **ECR Authentication Issues**
   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
   ```

2. **ECS Service Not Starting**
   - Check task definition logs in CloudWatch
   - Verify ECR image exists and is accessible
   - Check security group configurations

3. **ALB Health Check Failures**
   - Verify application is listening on correct port
   - Check health check path (`/health`)
   - Review security group rules

### Useful Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster production-devops-cicd-demo-cluster --services production-devops-cicd-demo-service

# View CloudWatch logs
aws logs describe-log-groups --log-group-name-prefix "/ecs/production-devops-cicd-demo"

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## Cleanup

To destroy all infrastructure:

```bash
./infrastructure/scripts/destroy.sh
```

**Warning**: This will permanently delete all AWS resources created by this project.

## Next Steps

### Production Enhancements
1. **Security**: Enable HTTPS with SSL certificates
2. **Monitoring**: Set up CloudWatch alarms and notifications
3. **Scaling**: Configure auto-scaling policies
4. **Backup**: Implement backup strategies
5. **Testing**: Add comprehensive test suites

### Advanced Features
1. **Blue/Green Deployments**: Implement zero-downtime deployments
2. **Canary Deployments**: Gradual rollout strategies
3. **Infrastructure as Code**: Use Terraform Cloud for state management
4. **Security Scanning**: Integrate container vulnerability scanning
5. **Cost Optimization**: Implement cost monitoring and optimization 