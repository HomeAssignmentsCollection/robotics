# 🔐 Secret Management Guide

This guide provides comprehensive best practices for managing secrets and sensitive information in the DevOps CI/CD pipeline.

## 🎯 Overview

Secret management is critical for securing sensitive information like API keys, passwords, and credentials. This guide covers multiple approaches for different environments and use cases.

## 🔐 Secret Management Strategies

### 1. **GitHub Secrets (Recommended for CI/CD)**

#### Setup
1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:

```bash
# Required AWS Credentials
AWS_ACCESS_KEY_ID=your_access_key_here
AWS_SECRET_ACCESS_KEY=your_secret_key_here
AWS_DEFAULT_REGION=eu-north-1

# ECR Registry Information
ECR_REGISTRY=your_account.dkr.ecr.region.amazonaws.com

# Optional: Additional Secrets
DOCKER_USERNAME=your_docker_username
DOCKER_PASSWORD=your_docker_password
SLACK_WEBHOOK_URL=your_slack_webhook_url
```

#### Usage in GitHub Actions
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_DEFAULT_REGION }}

- name: Login to Docker Registry
  run: |
    echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
```

### 2. **AWS Secrets Manager (Production)**

#### Store Secrets
```bash
# Store AWS credentials
aws secretsmanager create-secret \
  --name "devops-cicd-demo/aws-credentials" \
  --description "AWS credentials for DevOps CI/CD demo" \
  --secret-string '{"access_key_id":"your_access_key","secret_access_key":"your_secret_key"}' \
  --region eu-north-1

# Store Docker credentials
aws secretsmanager create-secret \
  --name "devops-cicd-demo/docker-credentials" \
  --description "Docker registry credentials" \
  --secret-string '{"username":"your_username","password":"your_password"}' \
  --region eu-north-1

# Store application secrets
aws secretsmanager create-secret \
  --name "devops-cicd-demo/app-secrets" \
  --description "Application secrets and configuration" \
  --secret-string '{"database_url":"your_db_url","api_key":"your_api_key"}' \
  --region eu-north-1
```

#### Retrieve Secrets
```bash
# Get secret value
aws secretsmanager get-secret-value \
  --secret-id "devops-cicd-demo/aws-credentials" \
  --region eu-north-1

# Parse JSON secret
SECRET_VALUE=$(aws secretsmanager get-secret-value \
  --secret-id "devops-cicd-demo/aws-credentials" \
  --region eu-north-1 \
  --query 'SecretString' \
  --output text)

ACCESS_KEY=$(echo $SECRET_VALUE | jq -r '.access_key_id')
SECRET_KEY=$(echo $SECRET_VALUE | jq -r '.secret_access_key')
```

### 3. **HashiCorp Vault (Enterprise)**

#### Setup Vault
```bash
# Install Vault
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vault

# Start Vault server
vault server -dev
```

#### Store and Retrieve Secrets
```bash
# Store secrets
vault kv put secret/devops-cicd-demo/aws \
  access_key_id=your_access_key \
  secret_access_key=your_secret_key

vault kv put secret/devops-cicd-demo/docker \
  username=your_username \
  password=your_password

# Retrieve secrets
vault kv get secret/devops-cicd-demo/aws
vault kv get secret/devops-cicd-demo/docker
```

### 4. **Environment Variables (Development)**

#### Local Development
```bash
# Set environment variables
export AWS_ACCESS_KEY_ID=your_access_key_here
export AWS_SECRET_ACCESS_KEY=your_secret_key_here
export AWS_DEFAULT_REGION=eu-north-1

# Use .env file (add to .gitignore)
cat > .env << EOF
AWS_ACCESS_KEY_ID=your_access_key_here
AWS_SECRET_ACCESS_KEY=your_secret_key_here
AWS_DEFAULT_REGION=eu-north-1
DOCKER_USERNAME=your_username
DOCKER_PASSWORD=your_password
EOF

# Load environment variables
source .env
```

#### AWS Profiles
```bash
# Configure AWS profiles
aws configure --profile devops-cicd-demo-dev
aws configure --profile devops-cicd-demo-prod

# Use specific profile
export AWS_PROFILE=devops-cicd-demo-dev
aws sts get-caller-identity
```

## 🔒 Security Best Practices

### 1. **Secret Rotation**
```bash
# Rotate AWS access keys
aws iam create-access-key --user-name your-username
aws iam delete-access-key --user-name your-username --access-key-id old-key-id

# Update secrets in GitHub
# Go to Settings → Secrets → Update the secret value

# Update AWS Secrets Manager
aws secretsmanager update-secret \
  --secret-id "devops-cicd-demo/aws-credentials" \
  --secret-string '{"access_key_id":"new_key","secret_access_key":"new_secret"}' \
  --region eu-north-1
```

### 2. **Access Control**
```bash
# IAM policies for least privilege
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:eu-north-1:123456789012:secret:devops-cicd-demo/*"
    }
  ]
}
```

### 3. **Audit and Monitoring**
```bash
# Enable CloudTrail for API calls
aws cloudtrail create-trail \
  --name devops-cicd-demo-trail \
  --s3-bucket-name your-log-bucket

# Monitor secret access
aws cloudwatch put-metric-alarm \
  --alarm-name "SecretAccessAlarm" \
  --alarm-description "Monitor secret access" \
  --metric-name "SecretAccessCount" \
  --namespace "AWS/SecretsManager" \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold
```

## 🚨 Security Considerations

### 1. **Never Commit Secrets**
```bash
# Add to .gitignore
echo ".env" >> .gitignore
echo "*.pem" >> .gitignore
echo "secrets/" >> .gitignore
echo "credentials.json" >> .gitignore
```

### 2. **Use Environment-specific Secrets**
```bash
# Development
export ENVIRONMENT=development
export AWS_PROFILE=devops-cicd-demo-dev

# Production
export ENVIRONMENT=production
export AWS_PROFILE=devops-cicd-demo-prod
```

### 3. **Encrypt Secrets at Rest**
```bash
# Enable encryption for AWS Secrets Manager
aws secretsmanager create-secret \
  --name "devops-cicd-demo/encrypted-secret" \
  --description "Encrypted secret" \
  --secret-string '{"key":"value"}' \
  --kms-key-id alias/aws/secretsmanager \
  --region eu-north-1
```

## 🔧 Integration Examples

### 1. **GitHub Actions with AWS Secrets Manager**
```yaml
- name: Get secrets from AWS Secrets Manager
  run: |
    SECRET_VALUE=$(aws secretsmanager get-secret-value \
      --secret-id "devops-cicd-demo/aws-credentials" \
      --region eu-north-1 \
      --query 'SecretString' \
      --output text)
    
    echo "AWS_ACCESS_KEY_ID=$(echo $SECRET_VALUE | jq -r '.access_key_id')" >> $GITHUB_ENV
    echo "AWS_SECRET_ACCESS_KEY=$(echo $SECRET_VALUE | jq -r '.secret_access_key')" >> $GITHUB_ENV
```

### 2. **Docker with Secrets**
```bash
# Docker Swarm secrets
echo "your_secret_password" | docker secret create db_password -

docker service create \
  --secret db_password \
  --name myapp \
  your-image:latest
```

### 3. **Kubernetes Secrets**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  username: <base64-encoded-username>
  password: <base64-encoded-password>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
      - name: app
        image: your-image:latest
        env:
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: username
```

## 📊 Monitoring and Alerting

### 1. **Secret Access Monitoring**
```bash
# CloudWatch metrics for secret access
aws cloudwatch put-metric-data \
  --namespace "Custom/Secrets" \
  --metric-data MetricName=SecretAccess,Value=1,Unit=Count

# Set up alarms
aws cloudwatch put-metric-alarm \
  --alarm-name "HighSecretAccess" \
  --alarm-description "High secret access rate" \
  --metric-name "SecretAccess" \
  --namespace "Custom/Secrets" \
  --statistic Sum \
  --period 300 \
  --threshold 100 \
  --comparison-operator GreaterThanThreshold
```

### 2. **Secret Expiration Monitoring**
```bash
# Check secret expiration
aws secretsmanager describe-secret \
  --secret-id "devops-cicd-demo/aws-credentials" \
  --query 'LastModifiedDate' \
  --output text
```

## 🚨 Troubleshooting

### Common Issues
1. **Permission Denied**: Check IAM policies and roles
2. **Secret Not Found**: Verify secret name and region
3. **Invalid Credentials**: Rotate and update credentials
4. **Network Issues**: Check VPC and security groups

### Debug Commands
```bash
# Test AWS credentials
aws sts get-caller-identity

# List secrets
aws secretsmanager list-secrets --region eu-north-1

# Test secret access
aws secretsmanager get-secret-value \
  --secret-id "devops-cicd-demo/aws-credentials" \
  --region eu-north-1
```

## 📚 Related Documentation

- **[QUICK_START.md](QUICK_START.md)**: Quick start with secret setup
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**: Common issues and solutions
- **[DOCKER_GUIDE.md](DOCKER_GUIDE.md)**: Docker secret management
- **[ARCHITECTURE_OVERVIEW.md](ARCHITECTURE_OVERVIEW.md)**: Security architecture

---

**Note**: This secret management guide ensures secure handling of sensitive information across all environments while maintaining compliance and audit requirements. 