# 🚀 Quick Start Guide

This guide will get you up and running with the DevOps CI/CD demo in under 30 minutes.

## Prerequisites Check

Before starting, ensure you have the following tools installed:

```bash
# Check if tools are installed
docker --version
aws --version
terraform --version
python3 --version
git --version
```

## Step 1: AWS Setup

### 1.1 Configure AWS CLI
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your default region (e.g., us-east-1)
# Enter your output format (json)
```

### 1.2 Verify AWS Access
```bash
aws sts get-caller-identity
# Should return your AWS account information
```

## Step 2: GitHub Repository Setup

### 2.1 Create GitHub Repository
1. Go to [GitHub](https://github.com) and create a new repository
2. Name it `devops-cicd-demo`
3. Make it public
4. Don't initialize with README (we already have one)

### 2.2 Push Code to GitHub
```bash
# Add remote origin
git remote add origin https://github.com/YOUR_USERNAME/devops-cicd-demo.git

# Push code
git add .
git commit -m "Initial commit"
git push -u origin main
```

### 2.3 Configure GitHub Secrets
1. Go to your repository on GitHub
2. Navigate to Settings > Secrets and variables > Actions
3. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

## Step 3: Deploy Infrastructure

### 3.1 Make Scripts Executable
```bash
chmod +x infrastructure/scripts/deploy.sh
chmod +x infrastructure/scripts/destroy.sh
```

### 3.2 Deploy AWS Infrastructure
```bash
./infrastructure/scripts/deploy.sh
```

This will:
- Create VPC with public/private subnets
- Set up ECR repository
- Create ECS cluster and service
- Deploy Application Load Balancer
- Configure CloudWatch monitoring

### 3.3 Get Deployment Outputs
```bash
cd infrastructure/terraform
terraform output
```

Note down the ALB DNS name for testing.

## Step 4: Test the Pipeline

### 4.1 Make a Code Change
```bash
# Edit the application
nano src/hello_world.py
# Change the message in the hello_world function
```

### 4.2 Push Changes
```bash
git add .
git commit -m "Test CI/CD pipeline"
git push origin main
```

### 4.3 Monitor Pipeline
1. Go to your GitHub repository
2. Click on "Actions" tab
3. Watch the pipeline execute:
   - ✅ Test job (linting and testing)
   - ✅ Build job (Docker build and ECR push)
   - ✅ Deploy job (ECS service update)

## Step 5: Verify Deployment

### 5.1 Check AWS Console
1. **ECR**: Verify new image was pushed
2. **ECS**: Check service is running with new task definition
3. **ALB**: Verify health checks are passing
4. **CloudWatch**: Check application logs

### 5.2 Test Application
```bash
# Get the ALB DNS name from terraform output
ALB_DNS=$(cd infrastructure/terraform && terraform output -raw alb_dns_name)

# Test the application
curl http://$ALB_DNS/
curl http://$ALB_DNS/health
curl http://$ALB_DNS/info
```

Expected responses:
```json
// GET /
{
  "message": "Hello from CI/CD!",
  "version": "2024.01.15-abc123",
  "build_date": "2024-01-15T10:30:00Z",
  "timestamp": "2024-01-15T10:30:00Z"
}

// GET /health
{
  "status": "healthy",
  "version": "2024.01.15-abc123",
  "timestamp": "2024-01-15T10:30:00Z"
}

// GET /info
{
  "name": "devops-cicd-demo",
  "version": "2024.01.15-abc123",
  "build_date": "2024-01-15T10:30:00Z",
  "environment": "production",
  "host": "your-alb-dns-name",
  "user_agent": "curl/7.68.0"
}
```

## Step 6: Local Development

### 6.1 Run Application Locally
```bash
# Install dependencies
pip install -r requirements.txt

# Run application
python src/hello_world.py
```

### 6.2 Build Docker Image Locally
```bash
# Build image
docker build -t devops-cicd-demo -f docker/Dockerfile .

# Run container
docker run -p 5000:5000 devops-cicd-demo
```

### 6.3 Run Tests Locally
```bash
# Install test dependencies
pip install pytest flake8

# Run tests
python -m pytest tests/ -v

# Run linting
flake8 src/ --count --select=E9,F63,F7,F82 --show-source --statistics
```

## Step 7: Monitoring and Troubleshooting

### 7.1 Check Application Logs
```bash
# View CloudWatch logs
aws logs describe-log-groups --log-group-name-prefix "/ecs/production-devops-cicd-demo"

# Get recent log events
aws logs get-log-events --log-group-name "/ecs/production-devops-cicd-demo" --log-stream-name "latest"
```

### 7.2 Check ECS Service Status
```bash
# Get service status
aws ecs describe-services \
  --cluster production-devops-cicd-demo-cluster \
  --services production-devops-cicd-demo-service
```

### 7.3 Check ALB Health
```bash
# Get target health
aws elbv2 describe-target-health \
  --target-group-arn $(aws elbv2 describe-target-groups --names production-devops-cicd-demo-tg --query 'TargetGroups[0].TargetGroupArn' --output text)
```

## Step 8: Cleanup

### 8.1 Destroy Infrastructure
```bash
./infrastructure/scripts/destroy.sh
```

**Warning**: This will permanently delete all AWS resources created by this project.

### 8.2 Remove GitHub Secrets
1. Go to your GitHub repository
2. Navigate to Settings > Secrets and variables > Actions
3. Delete the AWS secrets

## Troubleshooting

### Common Issues

#### 1. AWS Credentials Not Configured
```bash
# Error: Unable to locate credentials
aws configure
```

#### 2. Terraform State Lock
```bash
# Error: Error acquiring the state lock
terraform force-unlock <lock-id>
```

#### 3. ECS Service Not Starting
```bash
# Check task definition
aws ecs describe-task-definition --task-definition production-devops-cicd-demo-task

# Check service events
aws ecs describe-services --cluster production-devops-cicd-demo-cluster --services production-devops-cicd-demo-service
```

#### 4. ALB Health Check Failures
```bash
# Check security groups
aws ec2 describe-security-groups --group-names production-devops-cicd-demo-alb-sg

# Check target group health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

### Useful Commands

```bash
# Get all resources
aws resourcegroupstaggingapi get-resources --tag-filters Key=Environment,Values=production

# Check costs
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31 --granularity MONTHLY --metrics BlendedCost

# Monitor CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ServiceName,Value=production-devops-cicd-demo-service \
  --start-time 2024-01-15T00:00:00Z \
  --end-time 2024-01-15T23:59:59Z \
  --period 300 \
  --statistics Average
```

## Next Steps

After completing this quick start:

1. **Read the Documentation**:
   - [Setup Guide](docs/SETUP.md) - Detailed setup instructions
   - [Architecture](docs/ARCHITECTURE.md) - Complete architecture documentation
   - [Optimization](docs/OPTIMIZATION.md) - Performance and cost optimization
   - [Assignment Answers](docs/ANSWERS.md) - Comprehensive answers to all questions

2. **Explore Advanced Features**:
   - Implement blue/green deployments
   - Add security scanning
   - Set up cost monitoring
   - Configure custom metrics

3. **Production Considerations**:
   - Review security settings
   - Set up monitoring alerts
   - Implement backup strategies
   - Configure disaster recovery

## Support

If you encounter issues:

1. Check the [troubleshooting section](#troubleshooting)
2. Review AWS CloudWatch logs
3. Check GitHub Actions logs
4. Verify AWS service status
5. Consult the detailed documentation

---

**Happy Deploying! 🚀** 