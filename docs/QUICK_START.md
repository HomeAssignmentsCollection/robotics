# 🚀 Quick Start Guide

This guide will help you get up and running with the DevOps CI/CD pipeline project quickly.

## 📋 Prerequisites

Before you begin, ensure you have the following installed and configured:

### Required Tools
- **AWS CLI**: Configured with appropriate permissions
- **Terraform**: Version 1.0+ installed
- **Docker**: Docker Engine installed and running
- **Python**: Python 3.11+ installed
- **Git**: Git version control system

### AWS Configuration
```bash
# Configure AWS CLI
aws configure

# Verify AWS credentials
aws sts get-caller-identity
```

### 🔐 Secret Management Setup

#### GitHub Secrets (Recommended for CI/CD)
1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Add the following repository secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `AWS_DEFAULT_REGION`: eu-north-1
   - `ECR_REGISTRY`: Your ECR registry URL (e.g., `485701710361.dkr.ecr.eu-north-1.amazonaws.com`)

#### Local Development
```bash
# Option 1: Environment variables
export AWS_ACCESS_KEY_ID=your_access_key_here
export AWS_SECRET_ACCESS_KEY=your_secret_key_here
export AWS_DEFAULT_REGION=eu-north-1

# Option 2: AWS profiles
aws configure --profile devops-cicd-demo
```

#### Production Environment
```bash
# Use AWS Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id "devops-cicd-demo/aws-credentials" \
  --region eu-north-1

# Or use IAM roles for EC2/ECS
# (No credentials needed when running on AWS infrastructure)
```

### Required AWS Permissions
- ECR: Full access to container registry
- ECS: Full access to container service
- ALB: Full access to load balancer
- VPC: Full access to networking
- CloudWatch: Full access to monitoring
- IAM: Limited access for role creation

## 🚀 Step-by-Step Setup

### 1. Clone and Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd robotics

# Install Python dependencies
pip install -r requirements.txt
pip install -r code-quality/requirements.txt
```

### 2. Setup Code Quality

```bash
# Setup pre-commit hooks
bash code-quality/scripts/setup-pre-commit.sh

# Run quality checks
bash code-quality/scripts/run-quality-checks.sh
```

### 3. Version Management

```bash
# Initialize version (if needed)
./scripts/version.sh init

# Check current version
./scripts/version.sh get

# Show version information
./scripts/version.sh info

# Bump version (patch, minor, major)
./scripts/version.sh bump patch
```

### 4. Build and Test Docker Image

```bash
# Build Docker image
docker build -f docker/Dockerfile -t devops-cicd-demo:latest .

# Test Docker image locally
docker run --rm -p 5000:5000 devops-cicd-demo:latest

# Test health check
curl http://localhost:5000/health

# Test main endpoint
curl http://localhost:5000/

# Test info endpoint
curl http://localhost:5000/info
```

### 5. Deploy Infrastructure

```bash
# Navigate to infrastructure directory
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Deploy infrastructure
terraform apply -auto-approve

# Follow the prompts to configure your deployment
```

### 6. Test the Pipeline

```bash
# Make a change to the code
echo "# Updated comment" >> src/hello_world.py

# Commit and push
git add .
git commit -m "feat(app): update hello world message"
git push origin main
```

## 🔍 Verification Steps

### 1. Check Infrastructure Deployment

```bash
# Check VPC
aws ec2 describe-vpcs --region eu-north-1

# Check ECR repository
aws ecr describe-repositories --region eu-north-1

# Check ECS cluster
aws ecs describe-clusters --region eu-north-1

# Check ALB
aws elbv2 describe-load-balancers --region eu-north-1
```

### 2. Verify Application Deployment

```bash
# Get ALB DNS name
ALB_DNS=$(aws elbv2 describe-load-balancers \
  --region eu-north-1 \
  --query 'LoadBalancers[?LoadBalancerName==`production-devops-cicd-demo-alb`].DNSName' \
  --output text)

# Test application endpoints
curl http://$ALB_DNS/
curl http://$ALB_DNS/health
curl http://$ALB_DNS/info
```

### 3. Check CI/CD Pipeline

- **GitHub Actions**: https://github.com/HomeAssignmentsCollection/robotics/actions
- **ECR**: Check for new image tags
- **ECS**: Verify service is running with new image

## 🎯 Quick Commands Reference

### Version Management
```bash
./scripts/version.sh get          # Get current version
./scripts/version.sh bump patch   # Increment patch version
./scripts/version.sh info         # Show version information
./scripts/version.sh release      # Create release
```

### Quality Checks
```bash
bash code-quality/scripts/run-quality-checks.sh    # Run all quality checks
python code-quality/scripts/calculate-quality-index.py  # Calculate quality index
```

### Docker Operations
```bash
docker build -f docker/Dockerfile -t devops-cicd-demo:latest .  # Build image
docker run --rm -p 5000:5000 devops-cicd-demo:latest          # Run container
docker images devops-cicd-demo                                  # List images
```

### AWS Operations
```bash
aws sts get-caller-identity                                    # Check AWS identity
aws ecs describe-services --cluster production-devops-cicd-demo-cluster --region eu-north-1  # Check ECS
aws elbv2 describe-load-balancers --region eu-north-1         # Check ALB
```

### Terraform Operations
```bash
cd infrastructure/terraform
terraform plan                                                 # Plan changes
terraform apply -auto-approve                                 # Apply changes
terraform destroy -auto-approve                               # Destroy infrastructure
```

## 🚨 Common Issues and Solutions

### AWS Credentials Issues
```bash
# Check AWS credentials
aws sts get-caller-identity

# If credentials are missing, configure them
aws configure
```

### Docker Build Issues
```bash
# Check Docker is running
docker ps

# Clean up Docker cache
docker system prune -a

# Rebuild without cache
docker build --no-cache -f docker/Dockerfile -t devops-cicd-demo:latest .
```

### Terraform Issues
```bash
# Check Terraform version
terraform version

# Reinitialize Terraform
terraform init -reconfigure

# Check Terraform state
terraform show
```

### Quality Check Issues
```bash
# Install missing dependencies
pip install -r code-quality/requirements.txt

# Run individual quality checks
flake8 src/
pylint src/
bandit -r src/
```

## 📊 Monitoring and Verification

### Application Health
```bash
# Check application health
curl http://localhost:5000/health

# Check application info
curl http://localhost:5000/info

# Check application logs
docker logs container_name
```

### Infrastructure Health
```bash
# Check ECS service status
aws ecs describe-services \
  --cluster production-devops-cicd-demo-cluster \
  --services production-devops-cicd-demo-service \
  --region eu-north-1

# Check ALB target health
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:eu-north-1:485701710361:targetgroup/production-devops-cicd-demo-tg/abc123 \
  --region eu-north-1
```

### CloudWatch Monitoring
- **Dashboard**: https://eu-north-1.console.aws.amazon.com/cloudwatch/
- **Logs**: https://eu-north-1.console.aws.amazon.com/cloudwatch/home?region=eu-north-1#logsV2:log-groups
- **Alarms**: https://eu-north-1.console.aws.amazon.com/cloudwatch/home?region=eu-north-1#alarmsV2:

## 🔄 Next Steps

After successful setup:

1. **Explore Documentation**: Read the detailed documentation in the `docs/` folder
2. **Customize Configuration**: Modify Terraform variables for your environment
3. **Add Features**: Extend the application with new endpoints
4. **Optimize Performance**: Tune Docker and ECS configurations
5. **Enhance Security**: Review and improve security configurations
6. **Scale Up**: Add auto-scaling and monitoring improvements

## 📚 Related Documentation

- **[SETUP.md](SETUP.md)**: Detailed setup instructions
- **[ARCHITECTURE_OVERVIEW.md](ARCHITECTURE_OVERVIEW.md)**: System architecture
- **[VERSIONING_GUIDE.md](VERSIONING_GUIDE.md)**: Version management
- **[DOCKER_GUIDE.md](DOCKER_GUIDE.md)**: Docker best practices
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**: Common issues and solutions

---

**Note**: This quick start guide provides the essential steps to get the DevOps CI/CD pipeline running. For detailed information, refer to the comprehensive documentation in the `docs/` folder. 