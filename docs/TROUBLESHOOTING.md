# 🚨 Troubleshooting Guide

This guide provides solutions for common issues encountered when working with the DevOps CI/CD pipeline project.

## 🔍 Common Issues

### 1. AWS Credentials Issues

#### Problem: SignatureDoesNotMatch Error
```
Error: SignatureDoesNotMatch: The request signature we calculated does not match the signature you provided.
```

#### Solution:
```bash
# Check current AWS identity
aws sts get-caller-identity

# Configure AWS credentials
aws configure

# Set environment variables (use your actual credentials)
export AWS_ACCESS_KEY_ID=your_access_key_here
export AWS_SECRET_ACCESS_KEY=your_secret_key_here
export AWS_DEFAULT_REGION=eu-north-1
```

#### 🔐 Secret Management Best Practices:
```bash
# For CI/CD: Use GitHub Secrets
# Repository Settings → Secrets and variables → Actions
# Add: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION

# For Production: Use AWS Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id "devops-cicd-demo/aws-credentials" \
  --region eu-north-1

# For Development: Use AWS Profiles
aws configure --profile devops-cicd-demo
export AWS_PROFILE=devops-cicd-demo
```

#### Verification:
```bash
# Test AWS credentials
aws sts get-caller-identity

# Test specific service access
aws ec2 describe-regions --region eu-north-1
```

### 2. Terraform State Issues

#### Problem: State file conflicts or missing state
```
Error: Failed to get existing workspaces
```

#### Solution:
```bash
# Check Terraform state
terraform show

# Reinitialize Terraform
terraform init -reconfigure

# Check Terraform version
terraform version

# Validate configuration
terraform validate
```

#### State Management:
```bash
# List Terraform state
terraform state list

# Remove specific resource from state
terraform state rm aws_vpc.main

# Import existing resource
terraform import aws_vpc.main vpc-12345678
```

### 3. Docker Build Issues

#### Problem: Build failures or permission errors
```
Error: failed to solve: process "/bin/sh -c pip install" did not complete successfully
```

#### Solution:
```bash
# Check Docker is running
docker ps

# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker build --no-cache -f docker/Dockerfile -t devops-cicd-demo:latest .

# Check Docker disk space
docker system df
```

#### Permission Issues:
```bash
# Fix file permissions
chmod +x scripts/version.sh
chmod +x code-quality/scripts/*.sh

# Check Dockerfile permissions
ls -la docker/Dockerfile
```

### 4. Quality Check Issues

#### Problem: Quality check failures
```
Error: flake8: command not found
```

#### Solution:
```bash
# Install quality tools
pip install -r code-quality/requirements.txt

# Run individual quality checks
flake8 src/
pylint src/
bandit -r src/

# Check Python version
python --version
```

#### Common Quality Issues:
```bash
# Fix import issues
pip install -r requirements.txt

# Update dependencies
pip install --upgrade flake8 pylint bandit

# Check virtual environment
which python
```

### 5. Version Conflicts

#### Problem: Version script errors or conflicts
```
Error: Version file not found or invalid format
```

#### Solution:
```bash
# Check version file
cat VERSION

# Initialize version if missing
./scripts/version.sh init

# Validate version format
./scripts/version.sh validate

# Check Git tags
git tag -l
```

#### Version Management:
```bash
# Get current version
./scripts/version.sh get

# Show version info
./scripts/version.sh info

# Reset version if needed
echo "1.0.0" > VERSION
git add VERSION
git commit -m "chore: reset version to 1.0.0"
```

## 🔧 Debug Commands

### AWS Debugging
```bash
# Check AWS credentials
aws sts get-caller-identity

# List AWS regions
aws ec2 describe-regions

# Check specific service access
aws ecr describe-repositories --region eu-north-1
aws ecs describe-clusters --region eu-north-1
aws elbv2 describe-load-balancers --region eu-north-1
```

### Docker Debugging
```bash
# Check Docker status
docker info

# List containers
docker ps -a

# Check container logs
docker logs container_name

# Inspect container
docker inspect container_name

# Check resource usage
docker stats
```

### Terraform Debugging
```bash
# Check Terraform state
terraform show

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Check Terraform version
terraform version
```

### Application Debugging
```bash
# Test application locally
curl http://localhost:5000/health
curl http://localhost:5000/info

# Check application logs
docker logs container_name

# Execute commands in container
docker exec -it container_name /bin/bash
```

## 🚨 Infrastructure Issues

### 1. ECS Service Issues

#### Problem: ECS tasks not starting
```
Error: ECS service is not running tasks
```

#### Solution:
```bash
# Check ECS service status
aws ecs describe-services \
  --cluster production-devops-cicd-demo-cluster \
  --services production-devops-cicd-demo-service \
  --region eu-north-1

# Check ECS task definition
aws ecs describe-task-definition \
  --task-definition production-devops-cicd-demo-task \
  --region eu-north-1

# Check ECS events
aws ecs describe-services \
  --cluster production-devops-cicd-demo-cluster \
  --services production-devops-cicd-demo-service \
  --region eu-north-1 \
  --query 'services[0].events'
```

### 2. ALB Issues

#### Problem: Load balancer not accessible
```
Error: Connection refused or timeout
```

#### Solution:
```bash
# Check ALB status
aws elbv2 describe-load-balancers --region eu-north-1

# Check target group health
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:eu-north-1:485701710361:targetgroup/production-devops-cicd-demo-tg/abc123 \
  --region eu-north-1

# Check security groups
aws ec2 describe-security-groups --region eu-north-1
```

### 3. VPC Issues

#### Problem: Network connectivity issues
```
Error: Cannot reach application
```

#### Solution:
```bash
# Check VPC configuration
aws ec2 describe-vpcs --region eu-north-1

# Check subnets
aws ec2 describe-subnets --region eu-north-1

# Check route tables
aws ec2 describe-route-tables --region eu-north-1

# Check internet gateway
aws ec2 describe-internet-gateways --region eu-north-1
```

## 🔍 CI/CD Pipeline Issues

### 1. GitHub Actions Issues

#### Problem: Workflow failures
```
Error: GitHub Actions workflow failed
```

#### Solution:
- Check GitHub Actions logs: https://github.com/HomeAssignmentsCollection/robotics/actions
- Verify secrets are configured correctly
- Check AWS credentials in GitHub secrets
- Verify workflow syntax

#### Debug Steps:
```bash
# Check workflow files
cat .github/workflows/ci-cd.yml

# Validate YAML syntax
yamllint .github/workflows/*.yml

# Check GitHub secrets (in repository settings)
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_DEFAULT_REGION
```

### 2. ECR Issues

#### Problem: Cannot push to ECR
```
Error: no basic auth credentials
```

#### Solution:
```bash
# Login to ECR
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 485701710361.dkr.ecr.eu-north-1.amazonaws.com

# Check ECR repository
aws ecr describe-repositories --region eu-north-1

# List ECR images
aws ecr describe-images --repository-name devops-cicd-demo --region eu-north-1
```

### 3. Deployment Issues

#### Problem: Deployment fails or application not accessible
```
Error: Application not responding
```

#### Solution:
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

# Test application endpoints
curl http://production-devops-cicd-demo-alb-685489736.eu-north-1.elb.amazonaws.com/health
```

## 📊 Monitoring and Logs

### CloudWatch Debugging
```bash
# Check CloudWatch logs
aws logs describe-log-groups --region eu-north-1

# Get log events
aws logs get-log-events \
  --log-group-name /ecs/production-devops-cicd-demo \
  --log-stream-name ecs/app/abc123 \
  --region eu-north-1

# Check CloudWatch alarms
aws cloudwatch describe-alarms --region eu-north-1
```

### Application Logs
```bash
# Check application logs in container
docker logs container_name

# Check ECS task logs
aws logs get-log-events \
  --log-group-name /ecs/production-devops-cicd-demo \
  --region eu-north-1
```

## 🔧 Performance Issues

### 1. Docker Performance
```bash
# Check Docker resource usage
docker stats

# Clean up Docker resources
docker system prune -a

# Optimize Docker build
docker build --no-cache -f docker/Dockerfile -t devops-cicd-demo:latest .
```

### 2. Application Performance
```bash
# Check application response time
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:5000/health

# Monitor application metrics
curl http://localhost:5000/info

# Check container resource usage
docker stats container_name
```

### 3. Infrastructure Performance
```bash
# Check ECS CPU/Memory usage
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ServiceName,Value=production-devops-cicd-demo-service \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average \
  --region eu-north-1
```

## 🚨 Emergency Procedures

### 1. Rollback Deployment
```bash
# Rollback to previous version
aws ecs update-service \
  --cluster production-devops-cicd-demo-cluster \
  --service production-devops-cicd-demo-service \
  --task-definition production-devops-cicd-demo-task:previous \
  --region eu-north-1
```

### 2. Restart Service
```bash
# Force new deployment
aws ecs update-service \
  --cluster production-devops-cicd-demo-cluster \
  --service production-devops-cicd-demo-service \
  --force-new-deployment \
  --region eu-north-1
```

### 3. Destroy and Recreate
```bash
# Destroy infrastructure
cd infrastructure/terraform
terraform destroy -auto-approve

# Recreate infrastructure
terraform apply -auto-approve
```

## 📚 Related Documentation

- **[QUICK_START.md](QUICK_START.md)**: Quick start guide
- **[SETUP.md](SETUP.md)**: Detailed setup instructions
- **[ARCHITECTURE_OVERVIEW.md](ARCHITECTURE_OVERVIEW.md)**: System architecture
- **[VERSIONING_GUIDE.md](VERSIONING_GUIDE.md)**: Version management

## 🆘 Getting Help

If you encounter issues not covered in this guide:

1. **Check Logs**: Review application and infrastructure logs
2. **Verify Configuration**: Ensure all configurations are correct
3. **Test Incrementally**: Test each component separately
4. **Document Issues**: Keep notes of what you've tried
5. **Seek Community Help**: Use GitHub issues or community forums

---

**Note**: This troubleshooting guide covers the most common issues. For specific problems, check the logs and error messages for detailed information. 